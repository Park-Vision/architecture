workspace {
   
    model {
        admin = person "Admin" "Person managing the parking managers' accounts"
        parkingModerator = person "Parking Manager" "Person managing the parking lot, monitors the drone missions"
        guest = person "Not Authenticated User" "A user viewing the offer and system functionalities"
        logged_user = person "Authenticated User" "A system user who has an account and uses the system's functionalities"
      
        webSystem = softwareSystem "ParkVision System" "Allows users to view parking information, create reservations and pay for them" {


            viewApp = container "Web App" "Frontend responsible for the UI of the ParkVision" "React / JavaScript" {


                viewAppPages = component "pages" "" "React / JavaScript" {
                    admin -> this "Uses"
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
                
                
                
                apiAppControllers = component "Controller Layer" "" "Spring Controller" {
                    viewAppServices -> this "Make API requests to" "JSON/HTTP"
                    tags "Java"
                }

                apiAppServices = component "Service Layer" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppRepositories = component "DAO Layer" "" "Spring Repository" {
                    tags "Java"
                }
                apiAppConfigurations = component "Configuration Layer" "" "Spring Configuration" {
                }    
                apiAppKafka = component "Message Handler" "" "Spring Component" {
                }   

                
                apiAppControllers -> apiAppServices "Uses"
                apiAppServices -> apiAppRepositories "Uses"
                apiAppServices -> apiAppConfigurations "Uses" "Spring Bean"
                
                apiAppKafka -> viewAppServices "Sends real-time data" "WebSocket"
                apiAppKafka -> apiAppServices "Uses"
            }
         
            database = container "Database" "Application DB" "PostgreSQL" {
                tags "Database"
                apiApp -> this "Read and write to" "SQL/TCP"
                apiAppRepositories -> this "Stores/Retrieves"
            }
         
            droneBroker = container "Message Broker" "It mediates asynchronous communication" "Apache Kafka" {
                apiApp -> this "Sends real-time data to" "TLS1.2"
                this -> apiApp "Sends real-time data to" "TLS1.2"
                apiAppControllers -> this "Sends real-time data to" "TLS1.2"
                this -> apiAppKafka "Sends real-time data to" "TLS1.2"
            }
            
        }
        droneFirmware = softwareSystem "Drone Firmware" "Low level drone software" {
            tags "external system"
        }
      
        droneSystem = softwareSystem "Drone Mission Manager" "It handles communication with the drone system, manages the drone mission in real time, and transmits information to the ParkVision System" {
            droneBroker -> this "Sends real-time data to" "TLS1.2"
            this -> droneBroker "Sends real-time data to" "TLS1.2"
            
            missionManager = container "Mission manager service" "Drone and Kafka integration" {
                stateModule = component "Drone state machine" "Manages stages of drone mission and transitions between them" "python" {
                    tags "state"
                }
                decisionModule = component "decision" "Classifies parking spot as free or taken" "python" {
                    tags "decision"
                }
                missionModule = component "mission" "Mission planning and tracking" "python" {
                    tags "mission"
                }
                telemetryModule = component "telemetry" "Responsible for communication with server" "python" {
                    tags "telemetry"
                }
                
                stateModule -> telemetryModule "Uses" 
                stateModule -> decisionModule "Uses" 
                stateModule -> missionModule "Uses" 

                telemetryModule -> droneBroker "Sends real-time data to" "TLS1.2"
                droneBroker -> telemetryModule "Sends real-time data to" "TLS1.2"

                stateModule -> droneFirmware "Sends commands via the MAVlink protocol" 
                droneFirmware -> stateModule "Sends data via the MAVlink protocol" 
            }
        }
      

      
        systemPlatnosci = softwareSystem "Payment system" "Supports payments for reservations" {
            tags "external system"
            webSystem -> this "Sends data"
            apiApp -> this "Sends data" "JSON/HTTP"
            apiAppServices -> this "Sends data" "JSON/HTTP"
        }
      
        systemMailowy = softwareSystem "Email system" "Supports email sending" {
            tags "external system"
            this -> logged_user "Sends E-mail" 
            this -> parkingModerator "Sends E-mail"
            webSystem -> this "Sends data"
            apiApp -> this "Sends E-mail using"
            
            apiAppServices -> this "Sends E-mail using"
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
            include admin
        }
        
        component apiApp {
            include *
            include viewApp
            include systemMailowy
            include systemPlatnosci
            include droneBroker
        }

        component missionManager {
            include *
            include droneSystem
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
