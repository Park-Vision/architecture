workspace {

    model {
        parkingModerator = person "Parking Moderator" "A parking coordinator"
        client = person "Client" "A client of the parking"

        webSystem = softwareSystem "Park Vision System" "Allows customers to view information about parking, make reservations, payments" {
            viewApp = container "View Application" {
                client -> this "Uses"
                parkingModerator -> this "Uses"
            }
            apiApp = container "API Application" {

                signInController = component "Sign In Controller" {
                    viewApp -> this "Makes API calls to (JSON/HTTP)"
                }
                droneController = component "Drone Controller" {
                    viewApp -> this "Makes API calls to (JSON/HTTP)"
                }
            }
            database = container "Database" {
                signInController -> this "Reads from and writes to (SQL/TCP)"
            }
        }
        droneSystem = softwareSystem "Drone System" "Drone paths...." {
            droneController -> this "Makes API calls to"
        }
    }

    views {

        systemContext webSystem {
            include *
            autolayout lr
        }

        container webSystem {
            include *
            autolayout lr
        }

        component apiApp database droneSystem {
            include *
            autolayout lr
        }

        theme default
    }

}