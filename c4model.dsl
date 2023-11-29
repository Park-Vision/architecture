workspace {
   
    model {
        parkingModerator = person "Parking Manager" "Person managing the parking lot, monitors the drone missions"
        guest = person "Not Authenticated User" "A user viewing the offer and system functionalities"
        logged_user = person "Authenticated User" "A system user who has an account and uses the system's functionalities"

        
      
        webSystem = softwareSystem "Park Vision System" "Allows users to view parking information, create reservations and pay for them" {


            viewApp = container "Web App" "Frontend responsible for the UI of the ParkVision" "React / JavaScript" {


                viewAppPages = component "pages" "" "React / JavaScript" {
                    guest -> this "Uses"
                    parkingModerator -> this "Uses"
                    logged_user -> this "Uses"
                    tags "Pages"
                }

                viewAppRedux = component "redux" "" "React / JavaScript" {
                    tags "Redux"
                }

                viewAppComponents = component "components" "" "React / JavaScript" {
                    tags "Components"
                }

                viewAppUtils = component "utils" "" "React / JavaScript" {
                    tags "Utils"
                }

                viewAppAssets = component "assets" "" "React / JavaScript" {
                    tags "Assets"
                }

                viewAppServices = component "services" "" "JavaScript / Axios" {
                    tags "Services"
                }

                viewAppActions = component "Actions" "" "React / JavaScript" {
                    tags "Actions"
                }

                viewAppPages -> viewAppActions "Uses"
                viewAppPages -> viewAppUtils "Uses"
                viewAppComponents -> viewAppActions "Uses" 
                viewAppComponents -> viewAppAssets "Uses" "Assets"
                viewAppPages -> viewAppAssets "Uses" "Assets"
                viewAppActions -> viewAppServices "Uses" "Services"
                viewAppActions -> viewAppRedux "Uses" "Redux"
            }


            apiApp = container "Backend API Application" "Backend system supporting data processing and Kafka integration" "Spring Boot / Java" {
                viewApp -> this "Sends real-time data" "WebSocket"
                this -> viewApp "Sends real-time data" "WebSocket"
                
                viewApp -> this "Make API requests to" "JSON/HTTP"
                
                viewAppServices -> this "Make API requests to" "JSON/HTTP"
                
                
                viewAppServices -> this "Sends real-time data" "WebSocket"
                this -> viewAppServices "Sends real-time data" "WebSocket"
            }
         
            database = container "Database" "Application DB" "PostgreSQL" {
                tags "Database"
                apiApp -> this "Read and write to" "SQL/TCP"
            }
         
            droneBroker = container "Message Broker" "It mediates asynchronous communication" "Apache Kafka" {
                apiApp -> this "Sends real-time data to" "TLS1.2"
                this -> apiApp "Sends real-time data to" "TLS1.2"
            }
        }
      
        droneSystem = softwareSystem "Drone Mission Manager" "It handles communication with the drone system, manages the drone mission in real time, and transmits information to the Park Vision System" {
            droneBroker -> this "Sends real-time data to" "TLS1.2"
            this -> droneBroker "Sends real-time data to" "TLS1.2"
        }
      
        // droneFirmware = softwareSystem "Drone Firmware" "Drone software" {
        //     tags "external system"
        //     droneSystem -> this "Sends data via the MAVlink protocol"
        // }
      
        systemPlatnosci = softwareSystem "Payment system" "Supports payments for reservations" {
            tags "external system"
            webSystem -> this "Sends data"
            apiApp -> this "Sends data" "JSON/HTTP"
        }
      
        systemMailowy = softwareSystem "Email system" "Supports email sending" {
            tags "external system"
            this -> logged_user "Sends E-mail" {
            }
            webSystem -> this "Sends data"
            apiApp -> this "Sends E-mail using"
        }
    }
   
    views {
      
        systemContext webSystem {
            include *
            // include droneFirmware
        }
      
      
        container webSystem {
            include *
            // include droneFirmware
            include droneSystem
        }
      
        component viewApp {
            include *
            include apiApp
            include guest
            include logged_user
            include parkingModerator
        }
      
        theme default
      
        styles {
            element "external system" {
                background #B7B7B7
                shape RoundedBox
            }
         
            element "Database" {
                shape cylinder
            }
        }
    }
   
}
