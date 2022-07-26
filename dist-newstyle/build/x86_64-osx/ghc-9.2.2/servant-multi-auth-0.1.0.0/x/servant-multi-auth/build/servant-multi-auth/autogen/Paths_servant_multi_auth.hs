{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -w #-}
module Paths_servant_multi_auth (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where


import qualified Control.Exception as Exception
import qualified Data.List as List
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude


#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir `joinFileName` name)

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath



bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath
bindir     = "/Users/garethstokes/.cabal/bin"
libdir     = "/Users/garethstokes/.cabal/lib/x86_64-osx-ghc-9.2.2/servant-multi-auth-0.1.0.0-inplace-servant-multi-auth"
dynlibdir  = "/Users/garethstokes/.cabal/lib/x86_64-osx-ghc-9.2.2"
datadir    = "/Users/garethstokes/.cabal/share/x86_64-osx-ghc-9.2.2/servant-multi-auth-0.1.0.0"
libexecdir = "/Users/garethstokes/.cabal/libexec/x86_64-osx-ghc-9.2.2/servant-multi-auth-0.1.0.0"
sysconfdir = "/Users/garethstokes/.cabal/etc"

getBinDir     = catchIO (getEnv "servant_multi_auth_bindir")     (\_ -> return bindir)
getLibDir     = catchIO (getEnv "servant_multi_auth_libdir")     (\_ -> return libdir)
getDynLibDir  = catchIO (getEnv "servant_multi_auth_dynlibdir")  (\_ -> return dynlibdir)
getDataDir    = catchIO (getEnv "servant_multi_auth_datadir")    (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "servant_multi_auth_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "servant_multi_auth_sysconfdir") (\_ -> return sysconfdir)




joinFileName :: String -> String -> FilePath
joinFileName ""  fname = fname
joinFileName "." fname = fname
joinFileName dir ""    = dir
joinFileName dir fname
  | isPathSeparator (List.last dir) = dir ++ fname
  | otherwise                       = dir ++ pathSeparator : fname

pathSeparator :: Char
pathSeparator = '/'

isPathSeparator :: Char -> Bool
isPathSeparator c = c == '/'
