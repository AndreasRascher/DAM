table 91000 "DAM Object Setup"
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
}