workspace {
   
   model {
      parkingModerator = person "Parking manager" "Person managing the parking lot, monitors the drone missions"
      guest = person "Not authenticated user" "A user viewing the offer and system functionalities"
      logged_user = person "Authenticated user" "A system user who has an account and uses the system's functionalities"
      
      webSystem = softwareSystem "Park Vision System" "Allows users to view parking information, create reservations and pay for them" {
         viewApp = container "View Application" "" "React/ JavaScript" {
            guest -> this "Uses"
            parkingModerator -> this "Uses"
            logged_user -> this "Uses"            
         }
         apiApp = container "Backend API Application" "Backend system supporting data processing and Kafka integration" "Spring Boot / Java" {
            viewApp -> this "Make API requests to" "JSON/HTTP"
            
         }
         
         database = container "Database" "" "PostgreSQL" {
            tags "Database"
            apiApp -> this "Read and write to" "SQL/TCP"
         }
         
         droneBroker = container "Kafka" "It mediates asynchronous communication" "Apache Kafka" {   
            apiApp -> this "Sends data to" "TCP"
         }
         
         droneSystem = container "Drone Mission Manager" "It handles communication with the drone system, manages the drone mission in real time, and transmits information to the Park Vision System" {
            droneBroker -> this "Sends real-time data to" "TCP"
         }
      }
      
      
      
      
      droneFirmware = softwareSystem "Drone Firmware" "Drone software" {
         tags "external system"
         droneSystem -> this "Sends data via the MAVlink protocol"
      }
      
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
         include droneFirmware 
      }
      
      
      container webSystem {
         include *
         include droneFirmware
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