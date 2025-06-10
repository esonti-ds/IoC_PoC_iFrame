# ioc_poc_iframe

Proof of Concept to demonstrate the Bidirectional Communication using PostMessageAPI between Parent Flutter Application and Child Flutter Application hosted in an iframe in Parent Flutter Application

Context for the Runtime:
Parent Flutter Application is Diagnosis App (http://localhost:8080)
Child Flutter Application is Implant On Core App (http://localhost:9080)

```mermaid
flowchart TD
    subgraph Diagnosis App [Diagnosis App (http://localhost:8080)]
        direction TB
        subgraph ImplantOnCore [Implant on Core App (http://localhost:9080)]
        end
    end
```  

## Getting Started

Diagnosis App is modified to create an iframe that can load child flutter app into it. 

Steps to get started:
1. Modified Diagnosis App is available in Source Repo on 'IOC_AD_001_FrontendModulaization_POC_Option5' branch.
https://bitbucket.dentsplysirona.com/projects/DIA/repos/diagnosis/commits?until=refs%2Fheads%2FIOC_AD_001_FrontendModulaization_POC_Option5

2. Check-Out the Commit : 'e62299b65a3f36b3369b4a330b8c7de9faa419f4' on 'IOC_AD_001_FrontendModulaization_POC_Option5' branch. Or Download available at https://bitbucket.dentsplysirona.com/rest/api/latest/projects/DIA/repos/diagnosis/archive?at=811318a6029a46ad3197c5487d1f7c790692ef3c&format=zip

3. Build and Run Diagnosis App in your Local Environment 
    - make build .
    - flutter run -d web-server --web-port 8080

4. Build and Run Implant On Core App (This Proof of Concept Project) in your Local Environment
    - flutter pub get
    - flutter run -d web-server --web-port 9080

5. Open Development DS Core https://app-d2-euw4.d.dscore.com/ and Upload a PDF File with Name : 'IoC_PoC_iFrame.pdf' to DS Core Media Library.
Example File: A sample file is available in this project at other_files/IoC_PoC_iFrame.pdf 

6. Select 'IoC_PoC_iFrame.pdf' and click 'Open in Canvas' to initiate a Diagnosis Canvas Session.

7. Copy the part of the url '/#/lightbox/xxxxxxxxxxxx' and open in a browser Diagnosis App running in local environment with the copied url path
Example URL: http://localhost:8080/#/lightbox/xxxxxxxxxxxx

NOTE: Filename 'IoC_PoC_iFrame.pdf' is important, this is used as a hack in local Diagnosis App to create iframe with URL pointing to Implant On Core App (This Proof of Concept Project)

    - Filename 'IoC_PoC_iFrame.pdf' is used to instantiate a WebappViewer that hosts an iframe.
    - iframe in WebAppViewer is hardcoded to load http://localhost:9080 

8. Observe that it loads the Implant On Core App (http://localhost:9080) in an iframe inside the Viewer with Label 'WEBAPP' and Title 'IoC_PoC_iFrame.pdf'

## Proof Of Concept

1. Click on the 'info' tool for the WEBAPP Viewer. It will display the Media Details panel on the right-side.

2. Click and Drag anywhere on the CBCT Image displayed in the WEBAPP Viewer

3. Observe "Additional Information" with the Mouse Position Details appear in the Media Details panel.
    - Child (Implant on Core App - inside iframe) uses "PostMessageAPI" to send the Mouse Position Data while Dragging the Mouse to the Parent (Diagnosis App). 
    - Parent (Diagnosis App) receives the Mouse Position Data over PostMessageAPI and displays it in the Media Details Panel.

4. Observe a button in Orange Color and Mouse Icon inside the WEBAPP Viewer. Click it. It will show the following
    - Mouse Coordinates in the Child Flutter Application
    - Mouse Drag while Dragging the Mouse
    - "Request Token" Button

5. Click the "Request Token" Button
    - Child (Implant on Core App - inside iframe) uses "PostMessageAPI" to send Token Request to the Parent (Diagnosis App)
    - Parent (Diagnosis App) receives the Token Request over PostMessageAPI
    - Parent (Diagnosis App) uses "PostMessageAPI" to send the Token to the Child (Implant on Core App - inside iframe)
    - Child (Implant on Core App - inside iframe) receives the Token over PostMessageAPI and displays on screen.