table 81127 "DMTSetup"
{
    Caption = 'DMT Setup', comment = 'DMT Einrichtung';
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key', comment = 'Primärschlüssel'; }
        field(10; "Obj. ID Range Buffer Tables"; Text[250])
        { Caption = 'Obj. ID Range Buffer Tables', comment = 'Objekt ID Bereich für Puffertabellen'; }
        field(11; "Obj. ID Range XMLPorts"; Text[250])
        { Caption = 'Obj. ID Range XMLPorts (Import)', Comment = 'Objekt ID Bereich für XMLPorts (Import)'; }
        field(30; "Default Export Folder Path"; Text[250])
        {
            Caption = 'Default Export Folder', Comment = 'Standard Export Ordnerpfad';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                ServerFilePath: Text;
            begin

                if Rec."Default Export Folder Path" <> '' then begin
                    Rec."Default Export Folder Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
                    if not "Default Export Folder Path".EndsWith('\') then
                        REc."Default Export Folder Path" += '\'
                end;
                // Try Find Schema.csv
                if (Rec."Default Export Folder Path" <> '') and (Rec."Schema.csv File Path" = '') then begin
                    ServerFilePath := Rec."Default Export Folder Path" + 'Schema.csv';
                    if Exists(ServerFilePath) then
                        Rec."Schema.csv File Path" := ServerFilePath;
                end;
            end;

            trigger OnLookup()
            var
                DMTMgt: Codeunit DMTMgt;
            begin
                Rec."Default Export Folder Path" := DMTMgt.LookUpPath(Rec."Default Export Folder Path", true);
            end;
        }
        field(31; "Schema.csv File Path"; Text[250])
        {
            Caption = 'Schema File Path', Comment = 'Pfad Schemadatei';
            trigger OnValidate()
            begin
                Rec."Schema.csv File Path" := DelChr(Rec."Schema.csv File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DMTMgt: Codeunit DMTMgt;
            begin
                Rec."Schema.csv File Path" := DMTMgt.LookUpPath(Rec."Schema.csv File Path", false);
            end;
        }
        field(32; "Backup.xml File Path"; Text[250])
        {
            Caption = 'Backup.xml File Path', Comment = 'Pfad Backup.xml';
            trigger OnValidate()
            begin
                Rec."Backup.xml File Path" := DelChr(Rec."Backup.xml File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DMTMgt: Codeunit DMTMgt;
            begin
                Rec."Backup.xml File Path" := DMTMgt.LookUpPath(Rec."Backup.xml File Path", false);
            end;
        }
        field(40; "Allow Usage of Try Function"; Boolean)
        {
            Caption = 'Allow Usage of Try Function', Comment = ' Verwendung von Try Funktion zulassen';
            InitValue = true;
        }
        field(41; "Import with FlowFields"; Boolean)
        {
            Caption = 'Import with Flowfields', Comment = 'Import mit Flowfields';
        }
    }
    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }

    internal procedure InsertWhenEmpty()
    var
        fileMgt: Codeunit "File Management";
    begin
        if not Rec.Get() then begin
            Rec."Obj. ID Range Buffer Tables" := '90000..90099';
            Rec."Obj. ID Range XMLPorts" := '90000..90099';
            // Docker
            if fileMgt.ServerDirectoryExists('C:\RUN\MY') then
                Rec."Default Export Folder Path" := 'C:\RUN\MY';
            Rec.Insert();
        end;
    end;

    internal procedure ProposeObjectRanges()
    var
        ObjMgt: Codeunit DMTObjMgt;
    begin
        Rec."Obj. ID Range Buffer Tables" := ObjMgt.GetAvailableObjectIDsInLicenseFilter(Enum::DMTObjTypes::Table);
        Rec."Obj. ID Range XMLPorts" := ObjMgt.GetAvailableObjectIDsInLicenseFilter(Enum::DMTObjTypes::XMLPort);
    end;

    procedure CheckSchemaInfoHasBeenImporterd()
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        SchemaInfoMissingErr: TextConst ENU = 'The Schema.csv file has not been imported.', DEU = 'Die Schema.csv wurde nicht importiert.';
    begin
        if DMTFieldBuffer.IsEmpty then Error(SchemaInfoMissingErr);
    end;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get();
        RecordHasBeenRead := true;
    end;

    var
        RecordHasBeenRead: Boolean;
}