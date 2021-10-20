table 91000 "DAM Setup"
{
    CaptionML = DEU = 'DAM Objekt Einrichtung', ENU = 'DAM Object Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10]) { CaptionML = ENU = 'Primary Key', DEU = 'Primärschlüssel'; }
        field(10; "Obj. ID Range Buffer Tables"; Text[250])
        { CaptionML = DEU = 'Objekt ID Bereich für Puffertabellen', ENU = 'Obj. ID Range Buffer Tables'; }
        field(11; "Obj. ID Range XMLPorts"; Text[250])
        { CaptionML = DEU = 'Objekt ID Bereich für XMLPorts (Import)', ENU = 'Obj. ID Range XMLPorts (Import)'; }
        field(20; "Object ID Dataport (Export)"; Integer)
        {
            CaptionML = DEU = 'Objekt ID für Dataport (Export)', ENU = 'Object ID Dataport (Export)';
            MinValue = 50000;
            MaxValue = 99999;
        }
        field(30; "Default Export Folder Path"; Text[250])
        {
            CaptionML = DEU = 'Standard Export Ordnerpfad', ENU = 'Default Export Folder';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Rec."Default Export Folder Path" := DelChr(Rec."Default Export Folder Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DAMMgt: Codeunit DAMMgt;
            begin
                Rec."Default Export Folder Path" := DAMMgt.LookUpPath(Rec."Default Export Folder Path", true);
            end;
        }
        field(31; "Schema.xml File Path"; Text[250])
        {
            CaptionML = DEU = 'Pfad Schemadatei', ENU = 'Schema File Path';
            trigger OnValidate()
            begin
                Rec."Schema.xml File Path" := DelChr(Rec."Schema.xml File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DAMMgt: Codeunit DAMMgt;
            begin
                Rec."Schema.xml File Path" := DAMMgt.LookUpPath(Rec."Schema.xml File Path", false);
            end;
        }
        field(32; "Backup.xml File Path"; Text[250])
        {
            CaptionML = DEU = 'Pfad Backup.xml', ENU = 'Backup.xml File Path';
            trigger OnValidate()
            begin
                Rec."Backup.xml File Path" := DelChr(Rec."Backup.xml File Path", '<>', '"');
            end;

            trigger OnLookup()
            var
                DAMMgt: Codeunit DAMMgt;
            begin
                Rec."Backup.xml File Path" := DAMMgt.LookUpPath(Rec."Backup.xml File Path", false);
            end;
        }
        field(40; "Allow Usage of Try Function"; Boolean)
        {
            CaptionML = DEU = ' Verwendung von Try Funktion zulassen', ENU = 'Allow Usage of Try Function';
            InitValue = true;
        }
    }
    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }

    internal procedure InsertWhenEmpty()
    begin
        if not Rec.Get() then begin
            Rec."Obj. ID Range Buffer Tables" := '90000..90099';
            Rec."Obj. ID Range XMLPorts" := '90000..90099';
            Rec."Object ID Dataport (Export)" := 50004;
            Rec.Insert();
        end;
    end;

    procedure CheckSchemaInfoHasBeenImporterd()
    var
        DAMFieldBuffer: Record DAMFieldBuffer;
        SchemaInfoMissingErr: TextConst ENU = 'The Schema.txt file has not been imported.', DEU = 'Die Schema.txt wurde nicht importiert.';
    begin
        if DAMFieldBuffer.IsEmpty then Error(SchemaInfoMissingErr);
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