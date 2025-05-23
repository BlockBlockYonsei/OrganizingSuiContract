# SuiCracy : DAO for Validating Membership for Organizations

## Core Features 
### Select Executives
President appoints executive members (e.g. vice president, treasurer, etc) to support operations

### Recruiting
New members can request a recruitment ticket to join the club.

### Close Current Class Term & Create Next Class
Officially closing the current class or activity term

### Transfer Club Presidency
Smart contract facilitates seamless and secure transfer of authority between current and future president

## Quick Start
### Publishing contract
``` bash
git clone https://github.com/BlockBlockYonsei/OrganizingSuiContract.git
cd OrganizingSuiContract

// after finishing publish copy Package ID and BlockblockYonsei object ID
sui client publish
```
### Running OrganizingUI
``` bash
git clone https://github.com/BlockBlockYonsei/OrganizingUI.git
cd OrganizingUI

// Update PAKCAGE_ID
vi src/Contants.ts

yarn install
npm run dev
```
#### src/Constants.ts
export const ORIGINAL_PACKAGE_ID = "{YOUR_PACKAGE_ID}";
export const UPGRADED_PACKAGE_ID = "{YOUR_PACKAGE_ID}";
export const BLOCKBLOCK_YONSEI = "{YOUR_PACKAGE_BLOCKBLOCK_YONSEI_OBJECT_ID}";

## Technical Architecture
<img width="1636" alt="image" src="https://github.com/user-attachments/assets/191249a6-d4d8-4a0d-b383-2a765e8a237a" />


## Roadmap & Future Vision
### Phase 1:  Establishing Club Structure & Role-Based Permissions
Build each club and member database, including current members and alumni. Implement a hierarchical permission and access system that defines roles such as executive board and management staff.

### Phase 2: Extra Features – Governance and Certificates
Introduce features for submitting and voting on club proposals, as well as issuing activity-based certificates. The properties and design of each certificate will vary depending on the member’s level of participation.

### Phase 3: Expansion to general organization 
Open the platform to external institutions and organizations. Support broader use cases including student networks, NGOs, and different institutions around the world. 
