table 91004 DAMExportObject
{
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Code[10]) { CaptionML = ENU = 'Primary Key', DEU = 'Primärschlüssel'; }
        field(50; ExportDataPort; Blob) { }
        field(51; ExportXMLPort; Blob) { }
    }

    keys
    {
        key(Key1; "Primary Key") { Clustered = true; }
    }
    internal procedure InsertWhenEmpty()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Insert();
        end;
    end;
}