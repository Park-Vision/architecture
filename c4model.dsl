workspace {
   
   model {
      parkingModerator = person "Kierownik parkingu" "Osoba zarządzająca parkingiem, monitoruje misje dronowe"
      guest = person "Użytkownik niezalogowany" "Użytkownik przeglądający ofertę oraz funkcjonalności systemu"
      logged_user = person "Użytkownik zalogowany" "Użytkownik systemu, posiadający konto, korzystający z funkcjonalności systemu"
      
      webSystem = softwareSystem "Park Vision System" "Pozwala użytkownikom przeglądać informacje parkingów, tworzyć rezerwację oraz je opłacać" {
         viewApp = container "View Application" "React/ JavaScript" {
            guest -> this "Używa"
            parkingModerator -> this "Używa"
            logged_user -> this "Używa"            
         }
         apiApp = container "Backend API Application" "Spring Boot / Java" {
            viewApp -> this "Wykonuj żądania API do" "JSON/HTTP"
            
         }
         
         database = container "Database" "PostgreSQL" {
            apiApp -> this "Czytaj z i zapisuj do" "SQL/TCP"
         }

         droneBroker = container "Drone Backend" "Redis to Websocket, pośredniczy w komunikacji z dronem między innymi poprzez integrację Websocket z Redis i HTTP" {   
            this -> apiApp "Wysyła historie misji drona" "JSON/HTTP"
            viewApp -> this "Wysyła dane do" "WebSocket"
            this -> viewApp "Wysyła dane do" "WebSocket"
         }
      }

      
      droneSystem = softwareSystem "Drone Mission Manager" "Obsługuje komunikację z systemem drona, zarządza misją drona w czasie rzeczywistym i przesyła informacje do Park Vision System" {
         this -> webSystem "Wysyła dane"
         webSystem -> this "Wysyła dane"
         viewApp -> this "Wysyła dane w czasie rzeczywistym do" "WebSocket"
         this -> viewApp "Wysyła dane w czasie rzeczywistym do" "WebSocket"

      }
      
      droneFirmware = softwareSystem "Drone Firmware" "Oprogramowanie drona" {
         this -> droneSystem "Wysyła dane przez protokół MAVlink"
         droneSystem -> this "Wysyła dane przez protokół MAVlink"
      }
      
      systemPlatnosci = softwareSystem "System płatności" "Obsługuje płatności za rezerwacje" {
         this -> webSystem "Wysyła dane"
         webSystem -> this "Wysyła dane"
      }
      
      systemMailowy = softwareSystem "System mailowy" "Obsługuje wysyłanie wiadomości e-mail" {
         this -> logged_user "Wysyła E-mail"
         webSystem -> this "Wysyła dane"
         apiApp -> this "Wysyła E-mail używając"
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
