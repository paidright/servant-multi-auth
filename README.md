servant-multi-auth
====

use cabal to build and run this code

```
cabal new-build
cabal new-exec servant-multi-auth
```

Green, Red and Blue
----

The green endpoint is unauthorised and will work like such

```
curl -i localhost:3030/green
#=> 200 OK
```

The red endpoint uses cookie authentication

```
curl -i localhost:3030/red
#=> 400 BAD REQUEST

curl -i --cookie "Authorization=bad" localhost:3030/red
#=> 401 UNAUTHORIZED

curl -i --cookie "Authorization=letmein" localhost:3030/red
#=> 200 OK
```

The blue endpoint uses header authentication

```
curl -i localhost:3030/blue
#=> 400 BAD REQUEST

curl -i --header "Authorization: bad" localhost:3030/blue
#=> 401 UNAUTHORIZED

curl -i --cookie "Authorization: letmein" localhost:3030/blue
#=> 200 OK
```
