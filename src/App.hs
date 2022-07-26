{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App (run) where

import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC
import Data.Char (isSpace)
import Data.List (find)
import Data.Text (Text)
import Data.Word (Word8)
import qualified Network.HTTP.Types as HTTP
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import Servant
import Servant.Server.Experimental.Auth (
    AuthHandler,
    AuthServerData,
    mkAuthHandler,
 )
import System.IO

-- Api
--

type Api =
    ("green" :> Get '[PlainText] Text)
        :<|> AuthProtect "cookie" :> "red" :> Get '[PlainText] Text
        :<|> AuthProtect "header" :> "blue" :> Get '[PlainText] Text

newtype CookieCredentials = CookieCredentials Text
type instance AuthServerData (AuthProtect "cookie") = CookieCredentials

newtype HeaderCredentials = HeaderCredentials Text
type instance AuthServerData (AuthProtect "header") = HeaderCredentials

type AppContext =
    '[ AuthHandler Wai.Request CookieCredentials
     , AuthHandler Wai.Request HeaderCredentials
     ]

appContext :: Context AppContext
appContext =
    cookieHandler
        :. headerHandler
        :. EmptyContext

cookieHandler :: AuthHandler Wai.Request CookieCredentials
cookieHandler = mkAuthHandler f
  where
    f :: Wai.Request -> Handler CookieCredentials
    f request = do
        case cookieValue request of
            Nothing ->
                throwError err400
            Just "Authorization=letmein" ->
                pure $ CookieCredentials "OK"
            Just token -> do
                throwError err401

    cookieValue :: Wai.Request -> Maybe BSC.ByteString
    cookieValue request = do
        let headers = Wai.requestHeaders request
        (_k, v) <- flip find headers $ (== HTTP.hCookie) . fst
        let vs = fmap (BSC.dropWhile isSpace) (BS.split semicolon v)
        find (BS.isPrefixOf "Authorization=") vs

    semicolon :: Word8
    semicolon =
        59 {- ';' -}
    equal :: Word8
    equal =
        61 {- '=' -}

headerHandler :: AuthHandler Wai.Request HeaderCredentials
headerHandler = mkAuthHandler f
  where
    f :: Wai.Request -> Handler HeaderCredentials
    f request =
        case (authorizationHeader . Wai.requestHeaders) request of
            Nothing -> throwError err400
            Just (_, "letmein") -> pure $ HeaderCredentials "OK"
            Just _ -> throwError err401

    authorizationHeader :: [HTTP.Header] -> Maybe HTTP.Header
    authorizationHeader = find (\x -> fst x == HTTP.hAuthorization)

-- Handlers
--

green :: Handler Text
green = pure "OK"

red :: CookieCredentials -> Handler Text
red _ = pure "OK"

blue :: HeaderCredentials -> Handler Text
blue _ = pure "OK"

-- Main
--

run :: IO ()
run = do
    hSetBuffering stdout NoBuffering
    hSetBuffering stderr NoBuffering

    Warp.run 3030 app

app :: Wai.Application
app = serveWithContext (Proxy :: Proxy Api) appContext servers
  where
    servers = green :<|> red :<|> blue
