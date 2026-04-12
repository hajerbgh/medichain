# MediChain — Dossier Médical Décentralisé

> DApp Ethereum — le patient contrôle ses données de santé.


---

## Structure du projet

```
medichain/
├── contracts/
│   └── MediChain.sol        ← Smart contract Solidity 0.8.0
├── frontend/
│   └── index.html           ← Interface web (HTML + ethers.js v6)
└── README.md
```

---

## Outils requis (tous gratuits)

| Outil | Usage | Lien |
|-------|-------|------|
| Ganache | Blockchain locale | https://trufflesuite.com/ganache |
| MetaMask | Extension navigateur | https://metamask.io |
| Remix IDE | Compilation + déploiement | https://remix.ethereum.org |

---

## Lancer la démo — étapes

### 1. Ganache
- Ouvrir Ganache → **Quickstart Ethereum**
- RPC : `http://127.0.0.1:7545` · Chain ID : `1337`
- Copier la clé privée du compte 0 (icône clé)

### 2. MetaMask
- Ajouter réseau : RPC `http://127.0.0.1:7545` · Chain ID `1337` · Symbol `ETH`
- Importer compte → coller la clé privée → 100 ETH apparaissent

### 3. Remix
- Aller sur https://remix.ethereum.org
- Créer `MediChain.sol` → coller le contenu
- Compiler avec version `0.8.0`
- Deploy & Run → **Browser Extension (MetaMask)** → Deploy
- Copier l'adresse du contrat déployé

### 4. Interface
- Ouvrir `frontend/index.html` dans Chrome
- Connecter MetaMask
- Coller l'adresse du contrat → Connecter
- Tester : ajouter dossier, gérer accès, vérifier document

---

## Fonctions du smart contract

| Fonction | Accès | Description |
|----------|-------|-------------|
| `addRecord(patient, hash, type, title, desc)` | Patient ou médecin autorisé | Ancre un dossier on-chain |
| `grantAccess(doctor, specialty)` | Patient uniquement | Autorise un médecin |
| `revokeAccess(doctor)` | Patient uniquement | Révoque l'accès |
| `getRecords(patient)` | Patient ou médecin autorisé | Lit les dossiers |
| `verifyDocument(patient, hash)` | Patient ou médecin autorisé | Vérifie l'intégrité |

## Events

```
RecordAdded(patient, recordId, docType, timestamp)
AccessGranted(patient, doctor, specialty, timestamp)
AccessRevoked(patient, doctor, timestamp)
```

## Principes blockchain illustrés

| Principe | Implémentation MediChain |
|----------|--------------------------|
| Décentralisation | Aucun serveur central — Ganache/Ethereum |
| Immutabilité | Dossiers ancrés définitivement on-chain |
| Transparence | Events visibles dans le log de transactions |
| Consensus | Transactions validées par Ganache (automining) |
| Sans intermédiaire | Le smart contract remplace l'hôpital comme tiers de confiance |
