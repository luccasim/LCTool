# Template

# 7.0

## New

- Update Repository, now has a reference on every services
- Update template for Swift6 with actor and sendable objects
- Update test for use Testing
- Add new JSON template for SwiftUI Preview
- Remove alls protocols from usecase
- Usecase has only one dependances with repository
- Add Mock Repository
- Add ErrorHandleService

# 5.0

## News

- add Preview on Usecase repository
- now Preview file handles fakes DTO
- now Usecase file handle input / output and Errors flows
- update Repository file
- now Repository file uses Task and async functions
- update Endpoint
- remove alls interface on endpoint files
- now endpoint handle Task methods
- usecase protocol check input first, instead network reachability.
- usecase have options
- webservice handle switch mock server

# 4.2

## News

- Usecase can now disable snackBar notification errors
- Remove Fake on DTO, now it could be use on usecase
- Rework Task struct on service to Endpoint
- Endpoint could be create a URLRequest and set 2 methods for CAWebserviceManager jsonTask and jsonTask:cacheTimeSeconde
- jsonTask could be call for get jsonResponse
- jsonTask:cacheTimeSecondes store on cache the json response and return until the expire date
- remove preview on viewModel
- Update UITest for snapshot testing 
