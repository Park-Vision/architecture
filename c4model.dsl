workspace {
   
   model {
      parkingModerator = person "Kierownik parkingu" "Osoba zarządzająca parkingiem, monitoruje misje dronowe"
      guest = person "Użytkownik niezalogowany" "Użytkownik przeglądający ofertę oraz funkcjonalności systemu"
      logged_user = person "Użytkownik zalogowany" "Użytkownik systemu, posiadający konto, korzystający z funkcjonalności systemu"
      
      webSystem = softwareSystem "Park Vision System" "Pozwala użytkownikom przeglądać informacje parkingów, tworzyć rezerwację oraz je opłacać" {
         viewApp = container "View Application" "" "React/ JavaScript" {
            guest -> this "Używa"
            parkingModerator -> this "Używa"
            logged_user -> this "Używa"            
         }
         apiApp = container "Backend API Application" "System backendowy obsługujący przetwarzanie danych i integrację Kafka" "Spring Boot / Java" {
            viewApp -> this "Wykonuj żądania API do" "JSON/HTTP"
            
         }
         
         database = container "Database" "" "PostgreSQL" {
            tags "Database"
            apiApp -> this "Czytaj z i zapisuj do" "SQL/TCP"
         }
         
         droneBroker = container "Kafka" "Pośredniczy w komunikacji asynchronicznej" "Apache Kafka" {   
            apiApp -> this "Wysyła dane do" "Kafka"
         }
         
         droneSystem = container "Drone Mission Manager" "Obsługuje komunikację z systemem drona, zarządza misją drona w czasie rzeczywistym i przesyła informacje do Park Vision System" {
            droneBroker -> this "Wysyła dane w czasie rzeczywistym do" "Kafka"
         }
      }
      
      
      
      
      droneFirmware = softwareSystem "Drone Firmware" "Oprogramowanie drona" {
         tags "external system"
         droneSystem -> this "Wysyła dane przez protokół MAVlink"
      }
      
      systemPlatnosci = softwareSystem "System płatności" "Obsługuje płatności za rezerwacje" {
         tags "external system"
         webSystem -> this "Wysyła dane"
         apiApp -> this "Wysyła dane" "JSON/HTTP"
      }
      
      systemMailowy = softwareSystem "System mailowy" "Obsługuje wysyłanie wiadomości e-mail" {
         tags "external system"
         this -> logged_user "Wysyła E-mail" {
         }
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