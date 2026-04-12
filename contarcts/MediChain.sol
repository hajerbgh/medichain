// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title  MediChain
 * @notice Dossier médical décentralisé — le patient contrôle ses données
 * @dev    Compatible Remix IDE / Ganache / Sepolia
 */
contract MediChain {

    // ─────────────────────────────────────────
    //  STRUCTURES
    // ─────────────────────────────────────────

    struct MedicalRecord {
        uint256 id;
        string  docHash;
        string  docType;
        string  title;
        string  description;
        address addedBy;
        uint256 timestamp;
    }

    struct Doctor {
        bool    authorized;
        string  specialty;
        uint256 since;
    }

    // ─────────────────────────────────────────
    //  STOCKAGE
    // ─────────────────────────────────────────

    mapping(address => MedicalRecord[]) private _records;
    mapping(address => mapping(address => Doctor)) private _access;
    mapping(address => address[]) private _doctorList;
    uint256 private _counter;

    // ─────────────────────────────────────────
    //  EVENTS
    // ─────────────────────────────────────────

    event RecordAdded(
        address indexed patient,
        uint256 indexed recordId,
        string  docType,
        uint256 timestamp
    );

    event AccessGranted(
        address indexed patient,
        address indexed doctor,
        string  specialty,
        uint256 timestamp
    );

    event AccessRevoked(
        address indexed patient,
        address indexed doctor,
        uint256 timestamp
    );

    // ─────────────────────────────────────────
    //  MODIFIER
    // ─────────────────────────────────────────

    modifier canAccess(address patient) {
        require(
            msg.sender == patient ||
            _access[patient][msg.sender].authorized,
            "MediChain: acces refuse"
        );
        _;
    }

    // ─────────────────────────────────────────
    //  ECRITURE
    // ─────────────────────────────────────────

    /**
     * @notice Ajoute un dossier médical.
     * @dev    Utilise memory (pas calldata) pour éviter stack too deep.
     */
    function addRecord(
        address patient,
        string memory docHash,
        string memory docType,
        string memory title,
        string memory description
    ) external canAccess(patient) {
        require(bytes(docHash).length > 0, "MediChain: hash vide");
        require(bytes(title).length > 0,   "MediChain: titre vide");

        uint256 newId = _counter + 1;
        _counter = newId;

        _records[patient].push(MedicalRecord({
            id:          newId,
            docHash:     docHash,
            docType:     docType,
            title:       title,
            description: description,
            addedBy:     msg.sender,
            timestamp:   block.timestamp
        }));

        emit RecordAdded(patient, newId, docType, block.timestamp);
    }

    /**
     * @notice Autorise un médecin à accéder aux dossiers du patient.
     */
    function grantAccess(address doctor, string memory specialty) external {
        require(bytes(specialty).length > 0,             "MediChain: specialite vide");
        require(doctor != address(0),                    "MediChain: adresse nulle");
        require(doctor != msg.sender,                    "MediChain: auto-autorisation interdite");
        require(!_access[msg.sender][doctor].authorized, "MediChain: deja autorise");

        _access[msg.sender][doctor] = Doctor({
            authorized: true,
            specialty:  specialty,
            since:      block.timestamp
        });
        _doctorList[msg.sender].push(doctor);

        emit AccessGranted(msg.sender, doctor, specialty, block.timestamp);
    }

    /**
     * @notice Révoque l'accès d'un médecin.
     */
    function revokeAccess(address doctor) external {
        require(
            _access[msg.sender][doctor].authorized,
            "MediChain: medecin non autorise"
        );

        _access[msg.sender][doctor].authorized = false;

        address[] storage list = _doctorList[msg.sender];
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == doctor) {
                list[i] = list[list.length - 1];
                list.pop();
                break;
            }
        }

        emit AccessRevoked(msg.sender, doctor, block.timestamp);
    }

    // ─────────────────────────────────────────
    //  LECTURE
    // ─────────────────────────────────────────

    function getRecords(address patient)
        external view canAccess(patient)
        returns (MedicalRecord[] memory)
    {
        return _records[patient];
    }

    function getRecordCount(address patient)
        external view canAccess(patient)
        returns (uint256)
    {
        return _records[patient].length;
    }

    function isAuthorized(address patient, address doctor)
        external view returns (bool)
    {
        return _access[patient][doctor].authorized;
    }

    function getAuthorizedDoctors(address patient)
        external view returns (address[] memory)
    {
        require(msg.sender == patient, "MediChain: patients seulement");
        return _doctorList[patient];
    }

    function verifyDocument(address patient, string memory docHash)
        external view canAccess(patient)
        returns (bool found, uint256 recordId, uint256 ts)
    {
        bytes32 target = keccak256(bytes(docHash));
        MedicalRecord[] storage recs = _records[patient];
        for (uint256 i = 0; i < recs.length; i++) {
            if (keccak256(bytes(recs[i].docHash)) == target) {
                return (true, recs[i].id, recs[i].timestamp);
            }
        }
        return (false, 0, 0);
    }

    function totalRecords() external view returns (uint256) {
        return _counter;
    }
}
