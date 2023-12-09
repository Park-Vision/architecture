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
                
                
                
                apiAppControllers = component "Drone Controller" "" "Spring Controller" {
                    viewAppServices -> this "Make API requests to" "JSON/HTTP"
                    tags "Java"
                }

                apiAppServices = component "Drone Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppRepositories = component "Drone Repository" "" "Spring Repository" {
                    tags "Java"
                }
                apiAppConfigurations = component "Kafka Configuration" "" "Spring Configuration" {
                }
                apiAppKafka = component "Kafka Message Handler" "" "Spring Component" {
                }



                apiAppControllersRes = component "Reservation Controller" "" "Spring Controller" {
                    viewAppServices -> this "Make API requests to" "JSON/HTTP"
                    tags "Java"
                }
                apiAppControllersPay = component "Payment Controller" "" "Spring Controller" {
                    viewAppServices -> this "Make API requests to" "JSON/HTTP"
                    tags "Java"
                }
                apiAppControllersStripe = component "Stripe Charge Controller" "" "Spring Controller" {
                    viewAppServices -> this "Make API requests to" "JSON/HTTP"
                    tags "Java"
                }


                apiAppServicesParkingSpot = component "Parking Spot Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppServicesRes = component "Reservation Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppServicesPay = component "Payment Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppServicesEmail = component "Email Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppServicesStripe = component "Stripe Charge Service" "" "Spring Service Bean" {
                    tags "Java"
                }
                apiAppServicesDroneMission = component "Drone Mission Service" "" "Spring Service Bean" {
                    tags "Java"
                }

                apiAppRepositoriesDroneMission = component "Drone Mission Repository" "" "Spring Repository" {
                    tags "Java"
                }

                apiAppRepositoriesRes = component "Reservation Repository" "" "Spring Repository" {
                    tags "Java"
                }
                apiAppRepositoriesParkingSpot = component "Parking Spot Repository" "" "Spring Repository" {
                    tags "Java"
                }
                apiAppRepositoriesPay = component "Payment Repository" "" "Spring Repository" {
                    tags "Java"
                }
                apiAppRepositoriesStripe = component "Stripe Charge Repository" "" "Spring Repository" {
                    tags "Java"
                }



                apiAppControllersRes -> apiAppServicesRes "Uses"
                apiAppControllersRes -> apiAppServicesEmail "Uses"
                #apiAppControllersRes -> apiAppServicesParkingSpot "Uses"

                apiAppControllersStripe -> apiAppServicesRes "Uses"
                apiAppControllersStripe -> apiAppServicesEmail "Uses"
                apiAppControllersStripe -> apiAppServicesStripe "Uses"

                apiAppControllersPay -> apiAppServicesPay "Uses"


                apiAppServicesRes -> apiAppRepositoriesRes "Uses"
                apiAppServicesRes -> apiAppServicesParkingSpot "Uses"
                apiAppServicesRes -> apiAppServicesStripe "Uses"

                apiAppServicesStripe -> apiAppRepositoriesStripe "Uses"
                apiAppServicesStripe -> apiAppServicesPay "Uses"
                apiAppServicesPay -> apiAppRepositoriesPay "Uses"
                apiAppServicesParkingSpot -> apiAppRepositoriesParkingSpot "Uses"



                apiAppServices -> apiAppServicesParkingSpot "Uses"
                apiAppControllers -> apiAppServices "Uses"
                apiAppServices -> apiAppRepositories "Uses"
                apiAppServices -> apiAppConfigurations "Uses" "Spring Bean"
                
                apiAppKafka -> viewAppServices "Sends real-time data" "WebSocket"
                apiAppKafka -> apiAppServices "Uses"
                apiAppKafka -> apiAppServicesDroneMission "Uses"
                apiAppServicesDroneMission -> apiAppRepositoriesDroneMission "Uses"
            }


            database = container "Database" "Application DB" "PostgreSQL" {
                tags "Database"
                apiApp -> this "Read and write to" "SQL/TCP"
                apiAppRepositories -> this "Stores/Retrieves"
                apiAppRepositoriesParkingSpot -> this "Stores/Retrieves"
                apiAppRepositoriesRes -> this "Stores/Retrieves"
                apiAppRepositoriesPay -> this "Stores/Retrieves"
                apiAppRepositoriesStripe -> this "Stores/Retrieves"
                apiAppRepositoriesDroneMission -> this "Stores/Retrieves"
            }
         
            droneBroker = container "Message Broker" "It mediates asynchronous communication" "Apache Kafka" {
                apiApp -> this "Sends real-time data to" "TLS1.2"
                this -> apiApp "Sends real-time data to" "TLS1.2"
                apiAppServices -> this "Sends real-time data to" "TLS1.2"
                this -> apiAppKafka "Sends real-time data to" "TLS1.2"
            }
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
      
        // droneFirmware = softwareSystem "Drone Firmware" "Drone software" {
        //     tags "external system"
        //     droneSystem -> this "Sends data via the MAVlink protocol"
        // }
      
        systemPlatnosci = softwareSystem "Payment system" "Supports payments for reservations" {
            tags "external system"
            webSystem -> this "Sends data"
            apiApp -> this "Sends data" "JSON/HTTP"
            apiAppServicesStripe -> this "Sends data" "JSON/HTTP"
        }
      
        systemMailowy = softwareSystem "Email system" "Supports email sending" {
            tags "external system"
            this -> logged_user "Sends E-mail"
            this -> parkingModerator "Sends E-mail"
            webSystem -> this "Sends data"
            apiApp -> this "Sends E-mail using"
            
            apiAppServicesEmail -> this "Sends E-mail using"
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
            # include *
            include viewApp
            include apiAppServices
            include apiAppServicesParkingSpot
            #include systemMailowy
            # include systemPlatnosci
            include droneBroker
            include apiAppControllers
            include apiAppRepositories
            include database
            include apiAppKafka
            include apiAppConfigurations
            include apiAppServicesDroneMission
            include apiAppRepositoriesDroneMission

        }
        component apiApp {
            # include *
            include viewApp
            include systemMailowy
            include systemPlatnosci
            include apiAppControllersRes
            include viewAppServices
            include apiAppControllersPay
            include apiAppControllersStripe


            include apiAppServicesParkingSpot
            include apiAppServicesRes
            include apiAppServicesPay
            include apiAppServicesEmail
            include apiAppServicesStripe



            include apiAppRepositoriesRes
            #include apiAppRepositoriesParkingSpot
            include apiAppRepositoriesPay

            include apiAppRepositoriesStripe
            include database
            
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
