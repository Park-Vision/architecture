workspace {
   
   model {
      parkingModerator = person "Kierownik parkingu" "Osoba zarządzająca parkingiem"
      guest = person "Użytkownik niezalogowany" "Użytkownik przeglądający ofertę parkingu"
      logged_user = person "Użytkownik zalogowany" "Użytkownik systemu, posiadający konto"
      
      webSystem = softwareSystem "Park Vision System" "Allows customers to view information about parking, make reservations, payments" {
         viewApp = container "View Application" "React/ JavaScript" {
            guest -> this "Uses"
            parkingModerator -> this "Uses"
            logged_user -> this "Uses"            
         }
         apiApp = container "Backend API Application" "Spring Boot / Java" {
            viewApp -> this "Makes API calls to" "JSON/HTTP"
            
         }
         
         database = container "Database" "PostgreSQL" {
            apiApp -> this "Reads from and writes to" "SQL/TCP"
         }

         droneBroker = container "Drone Backend" "Redis to Websocket, Pośredniczy w komunikacji z dronem między innymi poprzez integrację Websocket z Redis i HTTP" {   
            this -> apiApp "Sends mission history to" "JSON/HTTP"
            viewApp -> this "Sends data to" "WebSockets"
            this -> viewApp "Sends data to" "WebSockets"
         }
      }

      
      droneSystem = softwareSystem "Drone Mission Manager" "Obsługuje komunikację z systemem drona, zarządza misją drona w czasie rzeczywistym i przesyła informacje do Park Vision System" {
         this -> webSystem "Sends data"
         webSystem -> this "Sends data"
         viewApp -> this "Sends realtime data to" "WebSockets"
         this -> viewApp "Sends realtime data to" "WebSockets"

      }
      
      droneFirmware = softwareSystem "Drone Firmware" "Oprogramowanie drona" {
         this -> droneSystem "Sends data via MAVlink protocol"
         droneSystem -> this "Sends data via MAVlink protocol"
      }
      
      systemPlatnosci = softwareSystem "System płatności" "Obsługuje płatności za rezerwacje" {
         this -> webSystem "Sends data"
         webSystem -> this "Sends data"
      }
      
      systemMailowy = softwareSystem "System mailowy" "Obsługuje wysyłanie maili" {
         this -> logged_user "Sends emails"
         webSystem -> this "Sends data"
         apiApp -> this "Sends e-mail using"
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
   }
   
}
