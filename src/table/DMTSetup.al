table 110008 DMTSetup
{
    Caption = 'DMT Setup', comment = 'DMT Einrichtung';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key', comment = 'Primärschlüssel'; }
        field(10; "Obj. ID Range Buffer Tables"; Text[250])
        {
            Caption = 'Obj. ID Range Buffer Tables', comment = 'Objekt ID Bereich für Puffertabellen';
            trigger OnValidate()
            var
                SessionStorage: Codeunit DMTSessionStorage;
            begin
                SessionStorage.DisposeLicenseInfo();
            end;
        }
        field(11; "Obj. ID Range XMLPorts"; Text[250])
        {
            Caption = 'Obj. ID Range XMLPorts (Import)', Comment = 'Objekt ID Bereich für XMLPorts (Import)';
            trigger OnValidate()
            var
                SessionStorage: Codeunit DMTSessionStorage;
            begin
                SessionStorage.DisposeLicenseInfo();
            end;
        }
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
                        Rec."Default Export Folder Path" += '\'
                end;
                // Try Find Schema.csv
                if (Rec."Default Export Folder Path" <> '') and (Rec."Schema.csv File Path" = '') then begin
                    ServerFilePath := Rec."Default Export Folder Path" + 'Schema.csv';
                    if Exists(ServerFilePath) then
                        Rec."Schema.csv File Path" := CopyStr(ServerFilePath, 1, MaxStrLen(Rec."Schema.csv File Path"));
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
                SyncSomeSettingsForAllCompanies(CompanyName);
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
        Company: Record Company;
        FromDMTSetup: Record DMTSetup;
        fileMgt: Codeunit "File Management";
        found: Boolean;
    begin
        if Rec.Get() then
            exit;
        Company.SetFilter(Name, '<>%1', CompanyName);
        if Company.FindSet() then
            repeat
                Clear(FromDMTSetup);
                FromDMTSetup.ChangeCompany(Company.Name);
                found := FromDMTSetup.FindFirst();
            until (Company.Next() = 0) or found;

        if found then begin
            Rec := FromDMTSetup;
            Rec.Insert();
            exit;
        end;

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
        SessionStorage: Codeunit DMTSessionStorage;
    begin
        SessionStorage.DisposeLicenseInfo();
        Rec."Obj. ID Range Buffer Tables" := CopyStr(ObjMgt.GetAvailableObjectIDsInLicenseFilter(Enum::DMTObjTypes::Table, true), 1, MaxStrLen(Rec."Obj. ID Range Buffer Tables"));
        Rec."Obj. ID Range XMLPorts" := CopyStr(ObjMgt.GetAvailableObjectIDsInLicenseFilter(Enum::DMTObjTypes::XMLPort, true), 1, MaxStrLen(Rec."Obj. ID Range XMLPorts"));
    end;

    procedure SyncSomeSettingsForAllCompanies(FromCompanyName: Text)
    var
        Company: Record Company;
        RecRefFrom, RecRefTo : RecordRef;
        FieldID: Integer;
        FieldIDsToSyncList: List of [Integer];
    begin
        FieldIDsToSyncList.Add(Rec.FieldNo("Obj. ID Range Buffer Tables"));
        FieldIDsToSyncList.Add(Rec.FieldNo("Obj. ID Range XMLPorts"));
        FieldIDsToSyncList.Add(Rec.FieldNo("Schema.csv File Path"));
        FieldIDsToSyncList.Add(Rec.FieldNo("Import with FlowFields"));

        RecRefFrom.GetTable(Rec);
        Company.SetFilter(Name, '<>%1', FromCompanyName);
        if Company.FindSet() then
            repeat
                Clear(RecRefTo);
                RecRefTo.Open(RecRefFrom.Number, false, Company.Name);
                if not RecRefTo.FindFirst() then
                    RecRefTo.Insert(false);
                foreach FieldID in FieldIDsToSyncList do
                    RecRefTo.Field(FieldID).Value := RecRefFrom.Field(FieldID).Value;
                RecRefTo.Modify(false);
            until Company.Next() = 0;
        RecRefTo.Open(RecRefFrom.Number);

    end;

    procedure CheckSchemaInfoHasBeenImporterd()
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
        SchemaInfoMissingErr: TextConst ENU = 'The Schema.csv file has not been imported. Please goto the DMT Setup an import the Schema.csv', DEU = 'Die Schema.csv wurde nicht importiert. Öffnen Sie die DMT Einrichtung und importiern Sie die Schema.csv';
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