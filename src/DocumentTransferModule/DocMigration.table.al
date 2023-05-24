table 73000 DMTDocMigration
{
    Caption = 'Document Migration';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Usage; Option)
        {
            OptionMembers = "DocMigrationSetup";
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; DataClassification = ToBeClassified; }
        field(3; "Line Type"; Option)
        {
            OptionMembers = " ",Structure,"Table";
            trigger OnValidate()
            var
                DocMigration: Record DMTDocMigration;
            begin
                if xRec."Line Type" <> Rec."Line Type" then begin
                    DocMigration.SetPosition(Rec.GetPosition());
                    DocMigration."Line Type" := Rec."Line Type";
                    if Rec."Line Type" = Rec."Line Type"::Structure then begin
                        Clear(Rec."Table Filter");
                        Clear(Rec.TableRelationJson);
                        Clear(Rec."Table ID");
                        Clear(Rec.DeleteRecordIfExits);
                        Clear(Rec."Attached to Line No.");
                        Clear(Rec.Description);
                    end;
                end;
            end;
        }
        field(11; Indentation; Integer) { Caption = 'Indentation'; }
        field(12; "Attached to Structure Line No."; Integer)
        {
            Caption = 'Attached to Structure Line No.';
            Editable = false;
        }
        field(13; "Attached to Line No."; Integer)
        {
            Caption = 'Attached to Line No.';
            Editable = false;
        }

        field(14; Description; Text[250]) { Caption = 'Description'; }
        field(20; "DataFile ID"; Integer) { Caption = 'Datafile ID'; TableRelation = DMTDataFile.ID; }
        field(30; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            BlankZero = true;
        }
        field(31; "Field ID"; Integer)
        {
            Caption = 'Fields ID';
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(32; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"),
                                                              "No." = field("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Related Table ID"; Integer)
        {
            Caption = 'Related Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(34; "Related Field ID"; Integer)
        {
            Caption = 'Related Field ID';
            TableRelation = Field."No." where(TableNo = field("Related Table ID"));
        }
        field(35; "Related Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Related Table ID"),
                                                              "No." = field("Related Field ID")));
            Caption = 'Related Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; "TableRelationJson"; Blob)
        {
            Caption = 'Table Relation JSON';
            Subtype = Json;
        }
        field(37; "Table Filter"; Blob) { Caption = 'Table Filter'; }
        field(40; DeleteRecordIfExits; Boolean) { Caption = 'Delete existing records before import'; }
    }

    keys
    {
        key(Key1; Usage, "Line No.") { Clustered = true; }

    }

    procedure CopyToTemp(var tempDocMigration: Record DMTDocMigration temporary) LineCount: Integer
    var
        docMigration: Record DMTDocMigration;
        tempDocMigration2: Record DMTDocMigration temporary;
    begin
        docMigration.Copy(Rec);
        if docMigration.FindSet(false, false) then
            repeat
                LineCount += 1;
                tempDocMigration2 := docMigration;
                tempDocMigration2.Insert(false);
            until docMigration.Next() = 0;
        tempDocMigration.Copy(tempDocMigration2, true);
    end;

    internal procedure IndentSelectedLines(var tempDocMigration: Record DMTDocMigration temporary; Direction: Integer)
    var
        docMigration: Record DMTDocMigration;
    begin
        if not tempDocMigration.FindSet() then exit;
        repeat
            docMigration.Get(tempDocMigration.RecordId);
            docMigration.Indentation += Direction;
            if docMigration.Indentation < 0 then
                docMigration.Indentation := 0;
            docMigration.Modify();
            docMigration.UpdateStructureFields();
            docMigration.Modify();
        until tempDocMigration.Next() = 0;
    end;

    procedure UpdateStructureFields()
    var
        docMigration: Record DMTDocMigration;
    begin
        // Init Attached to Structure Line No.
        Rec."Attached to Structure Line No." := 0;
        // Init Attached to Line No.
        Rec."Attached to Line No." := 0;

        // Find Structure Line
        if Rec."Line Type" = Rec."Line Type"::Structure then begin
            Rec."Attached to Structure Line No." := Rec."Line No.";
            exit;
        end;
        // Find Parent Structure Line
        docMigration := Rec;
        while docMigration.Next(-1) = -1 do begin
            if docMigration."Line Type" = docMigration."Line Type"::Structure then begin
                Rec."Attached to Structure Line No." := docMigration."Line No.";
                break;
            end;
        end;

        // Find Parent Line
        docMigration := Rec;
        while docMigration.Next(-1) = -1 do begin
            if docMigration."Line Type" = docMigration."Line Type"::Structure then begin
                break;
            end else begin
                if Rec.Indentation > docMigration.Indentation then begin
                    Rec."Attached to Line No." := docMigration."Line No.";
                    if docMigration."Table ID" <> 0 then begin
                        Rec."Related Table ID" := docMigration."Table ID";
                    end;
                    break;
                end;
            end;
        end;

    end;

    procedure LoadTableRelation(var tempDocMigrationNew: Record DMTDocMigration temporary) NoOfLines: Integer
    var
        TempDocMigration: Record DMTDocMigration temporary;
        i: Integer;
        JArray: JsonArray;
        JToken, JToken2 : JsonToken;
        Old: Text;
    begin
        if JArray.ReadFrom(ReadFromBlob(Rec.FieldNo(TableRelationJson))) then;
        for i := 1 to JArray.Count do begin
            Clear(TempDocMigration);
            JArray.Get(i - 1, JToken);
            TempDocMigration."Line No." := i * 10000;
            Old := Format(TempDocMigration);
            if JToken.AsObject().Get('FromTableID', JToken2) then
                TempDocMigration."Table ID" := JToken2.AsValue().AsInteger();
            if JToken.AsObject().Get('FromFieldID', JToken2) then
                TempDocMigration."Field ID" := JToken2.AsValue().AsInteger();
            if JToken.AsObject().Get('RelatedTableID', JToken2) then
                TempDocMigration."Related Table ID" := JToken2.AsValue().AsInteger();
            if JToken.AsObject().Get('RelatedFieldID', JToken2) then
                TempDocMigration."Related Field ID" := JToken2.AsValue().AsInteger();
            if Old <> Format(TempDocMigration) then
                TempDocMigration.Insert();
        end;
        tempDocMigrationNew.Copy(TempDocMigration, true);
        NoOfLines := tempDocMigrationNew.Count;
    end;

    procedure SaveTableRelation(var TempDocMigrationNew: Record DMTDocMigration temporary) NoOfLines: Integer
    var
        TempDocMigration: Record DMTDocMigration temporary;
        JArray: JsonArray;
        JObj: JsonObject;
        JSON: Text;
    begin
        TempDocMigration.Copy(TempDocMigrationNew, true);
        if TempDocMigration.FindSet() then
            repeat
                Clear(JObj);
                JObj.Add('FromTableID', TempDocMigration."Table ID");
                JObj.Add('FromFieldID', TempDocMigration."Field ID");
                JObj.Add('RelatedTableID', TempDocMigration."Related Table ID");
                JObj.Add('RelatedFieldID', TempDocMigration."Related Field ID");
                JArray.Add(JObj);
            until TempDocMigration.Next() = 0;
        NoOfLines := JArray.Count;
        JArray.WriteTo(JSON);
        WriteToBlob(Rec.FieldNo(TableRelationJson), JSON);
    end;

    procedure ReadFromBlob(FieldID: Integer) Content: Text
    var
        IStr: InStream;
    begin
        case FieldID of
            Rec.FieldNo("Table Filter"):
                begin
                    Rec.CalcFields("Table Filter");
                    if not Rec."Table Filter".HasValue then exit('');
                    Rec."Table Filter".CreateInStream(IStr);
                    IStr.ReadText(Content);
                end;
            Rec.FieldNo(TableRelationJson):
                begin
                    Rec.CalcFields(TableRelationJson);
                    if not Rec.TableRelationJson.HasValue then exit('');
                    Rec.TableRelationJson.CreateInStream(IStr);
                    IStr.ReadText(Content);
                end;
            else
                Error('unhandled FieldID');
        end;
    end;

    procedure WriteToBlob(FieldID: Integer; Content: Text)
    var
        OStr: OutStream;
    begin
        case FieldID of
            Rec.FieldNo("Table Filter"):
                begin
                    Clear(Rec."Table Filter");
                    Rec.Modify();
                    Rec."Table Filter".CreateOutStream(OStr);
                end;
            Rec.FieldNo(TableRelationJson):
                begin
                    Clear(Rec.TableRelationJson);
                    Rec.Modify();
                    Rec.TableRelationJson.CreateOutStream(OStr);
                end;
            else
                Error('unhandled FieldID');
        end;
        OStr.WriteText(Content);
        Rec.Modify();
    end;

    procedure EditTableFilter()
    var
        FilterPage: Codeunit DMTFPBuilder;
        RecRef: RecordRef;
    begin
        if Rec."Line Type" <> Rec."Line Type"::Table then
            exit;

        if Rec.ReadFromBlob(rec.FieldNo("Table Filter")) <> '' then begin
            // Reuse old filter
            FilterPage.OpenRecRefWithFilters(RecRef, rec."DataFile ID", Rec.ReadFromBlob(rec.FieldNo("Table Filter")));
            if FilterPage.RunModal(RecRef, true) then begin
                Rec.WriteToBlob(Rec.FieldNo("Table Filter"), '');
                if RecRef.HasFilter then
                    Rec.WriteToBlob(Rec.FieldNo("Table Filter"), FilterPage.GetFiltersFrom(RecRef));
            end;
        end else begin
            // New filter
            FilterPage.OpenRecRefWithFilters(RecRef, rec."DataFile ID", '');
            if FilterPage.RunModal(RecRef, true) then begin
                Rec.WriteToBlob(Rec.FieldNo("Table Filter"), '');
                if RecRef.HasFilter then
                    Rec.WriteToBlob(Rec.FieldNo("Table Filter"), FilterPage.GetFiltersFrom(RecRef));
            end;
        end;
    end;

    procedure GetTableFilterDescr() TableFilterDescr: Text
    var
        FilterPage: Codeunit DMTFPBuilder;
        recRef: RecordRef;
        Filters: Text;
    begin
        if Rec."Line Type" in [Rec."Line Type"::Table] then begin
            Filters := rec.ReadFromBlob(rec.FieldNo("Table Filter"));
            if Filters = '' then
                exit('<click to edit>');
            FilterPage.RestorFiltersForRecRef(recRef, Filters, false);
            TableFilterDescr := recRef.GetFilters;
        end else
            exit('');
    end;

    procedure FindSetChildNodes(var docMigration: Record DMTDocMigration) FindSetOK: Boolean
    begin
        clear(docMigration);
        docMigration.SetRange("Attached to Line No.", rec."Line No.");
        docMigration.SetRange("Attached to Structure Line No.", rec."Attached to Structure Line No.");
        FindSetOK := docMigration.FindSet();
    end;



}