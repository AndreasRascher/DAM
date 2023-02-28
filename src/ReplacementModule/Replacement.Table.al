table 110011 DMTReplacement
{
    DataClassification = ToBeClassified;

    fields
    {

        #region TableKeys
        field(1; LineType; Option)
        {
            Caption = 'Line Type';
            OptionMembers = Header,Line,Assignment;
        }
        field(2; "Replacement Code"; Code[100])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = if (LineType = const(Assignment)) DMTReplacement."Replacement Code" where(LineType = const(Header));
            ValidateTableRelation = false;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Description"; Text[100]) { Caption = 'Description'; }
        #endregion TableKeys
        #region Compare Values
        field(100; "No. of Compare Values"; Option)
        {
            Caption = 'No. of Compare Values', Comment = 'de-DE=Anz. Vergleichswerte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(110; "Comp.Value 1"; Text[80]) { Caption = 'Compare Value 1', Comment = 'Vgl.-Wert 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("Comp.Value 1")); }
        field(111; "Comp.Val.1 Caption"; Text[80]) { Caption = 'Compare Field 1 Caption', Comment = 'Vgl.-Wert 1 Bezeichnung'; }
        // field(112; "Rel.to Table ID (Comp.Val.1)"; Integer)
        // {
        //     Caption = 'Related to Table ID (Comp.Val.1)', Comment = 'Tabellenrelation ID (Vergleichswert 1)';
        //     TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        //     DataClassification = SystemMetadata;
        //     trigger OnValidate()
        //     begin
        //         CalcFields("Rel.to Table Cpt.(Comp.Val.1)");
        //     end;
        // }
        // field(113; "Rel.to Table Cpt.(Comp.Val.1)"; Text[100])
        // {
        //     Caption = 'Related Table Caption (New Val.1)', Comment = 'Tabelle (Vergleichswert 1)';
        //     FieldClass = FlowField;
        //     CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (Comp.Val.1)")));
        //     Editable = false;
        // }
        field(120; "Comp.Value 2"; Text[80]) { Caption = 'Compare Value 2', Comment = 'Vgl.-Wert 2'; CaptionClass = Rec.GetCaption(Rec.FieldNo("Comp.Value 2")); }
        field(121; "Comp.Val.2 Caption"; Text[80]) { Caption = 'Compare Field 2 Caption'; }
        #endregion Compare Values
        #region NewValues
        field(200; "No. of Values to modify"; Option)
        {
            Caption = 'No. of Values to modify', Comment = 'de-DE=Anz. zu ändernder Werte';
            OptionMembers = "1","2";
            OptionCaption = '1,2', Locked = true;
        }
        field(210; "New Value 1"; Text[250]) { Caption = 'New Value 1', Comment = 'Neuer Wert 1'; CaptionClass = Rec.GetCaption(Rec.FieldNo("New Value 1")); }
        field(211; "New Value 1 Caption"; Text[80]) { Caption = 'New Value 1 Caption', Comment = 'Neuer Wert 1 Bezeichnung'; }
        field(212; "Rel.to Table ID (New Val.1)"; Integer)
        {
            Caption = 'Related to Table ID (New.Fld.1)', Comment = 'Tabellenrelation ID (Neu 1)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.to Table Cpt.(New Val.1)");
            end;
        }
        field(213; "Rel.to Table Cpt.(New Val.1)"; Text[100])
        {
            Caption = 'Related Table Caption (New Val.1)', Comment = 'Relation zu Tabelle (Neu 1)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (New Val.1)")));
            Editable = false;
        }
        field(220; "New Value 2"; Text[80]) { Caption = 'New Value 2 Caption', Comment = 'Neuer Wert 2 Bezeichnung'; CaptionClass = Rec.GetCaption(Rec.FieldNo("New Value 2")); }
        field(221; "New Value 2 Caption"; Text[80]) { Caption = 'New Value 2 Caption', Comment = 'Neuer Wert 2 Bezeichnung'; }
        field(222; "Rel.to Table ID (New Val.2)"; Integer)
        {
            Caption = 'Related to Table ID (New Val.2)', Comment = 'Tabellenrelation ID (Neu 2)';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;
            trigger OnValidate()
            begin
                CalcFields("Rel.to Table Cpt.(New Val.1)");
            end;
        }
        field(223; "Rel.to Table Cpt.(New Val.2)"; Text[100])
        {
            Caption = 'Related Table Caption (New Val.2)', Comment = 'Relation zu Tabelle (Neu 2)';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Rel.to Table ID (New Val.2)")));
            Editable = false;
        }
        #endregion NewValues
        field(300; "No. of Lines"; Integer)
        {
            Caption = 'No. of Lines', comment = 'de-DE=Anzahl Zeilen';
            FieldClass = FlowField;
            CalcFormula = count(DMTReplacement where(LineType = const(Line), "Replacement Code" = field("Replacement Code")));
            Editable = false;
        }
        #region DataFileTargetFieldAssignment
        field(400; "Data File ID"; Integer)
        {
            Caption = 'Datafile ID';
            TableRelation = DMTDataFile.ID;
        }
        field(401; "Data File Name"; Text[250])
        {
            Caption = 'Datafile Name', Comment = 'de-DE=Dateiname';
            FieldClass = FlowField;
            CalcFormula = lookup(DMTDataFile.Name where(ID = field("Data File ID")));
            Editable = false;
        }
        field(402; "Target Table ID"; Integer)
        {
            Caption = 'Target Table ID', comment = 'Ziel Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(403; "Compare Value 1 Field No."; Integer)
        {
            Caption = 'Compare Value 1 Field No.', comment = 'Vgl.-Wert 1 Feld Nr.';
            TableRelation = DMTFieldMapping."Source Field No." where("Target Table ID" = field("Target Table ID"), "Source Field No." = field("Compare Value 1 Field No."));
        }
        field(404; "Compare Value 2 Field No."; Integer)
        {
            Caption = 'Compare Value 2 Field No.', comment = 'Vgl.-Wert 2 Feld Nr.';
            TableRelation = DMTFieldMapping."Source Field No." where("Target Table ID" = field("Target Table ID"), "Source Field No." = field("Compare Value 2 Field No."));
        }
        field(405; "New Value 1 Field No."; Integer)
        {
            Caption = 'Compare Value 1 Field No.', comment = 'Vgl.-Wert 1 Feld Nr.';
            TableRelation = DMTFieldMapping."Target Field No." where("Target Table ID" = field("Target Table ID"), "Target Field No." = field("New Value 1 Field No."));
        }
        field(406; "New Value 2 Field No."; Integer)
        {
            Caption = 'Compare Value 2 Field No.', comment = 'Vgl.-Wert 2 Feld Nr.';
            TableRelation = DMTFieldMapping."Target Field No." where("Target Table ID" = field("Target Table ID"), "Target Field No." = field("New Value 2 Field No."));
        }
        #endregion DataFileTargetFieldAssignment
    }

    keys
    {
        key(Key1; LineType, "Replacement Code", "Line No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "Replacement Code", Description) { }
    }

    trigger OnInsert()
    begin
        case Rec.LineType of
            Rec.LineType::Header:
                Rec.TestField("Line No.", 0);
            Rec.LineType::Line:
                Rec.TestField("Line No.");
            Rec.LineType::Assignment:
                begin
                    Rec.Testfield("Data File ID");
                    Rec.Testfield("Replacement Code");
                    Rec."Line No." := Rec."Data File ID";
                end;
        end;
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    var
        DMTReplacement: Record DMTReplacement;
    begin
        if Rec.LineType = Rec.LineType::Header then begin
            DMTReplacement.SetRange("Replacement Code", rec."Replacement Code");
            DMTReplacement.SetRange(LineType, Rec.LineType::Line);
            if not DMTReplacement.IsEmpty then
                DMTReplacement.DeleteAll();
            DMTReplacement.SetRange("Replacement Code", rec."Replacement Code");
            DMTReplacement.SetRange(LineType, Rec.LineType::Assignment);
            if not DMTReplacement.IsEmpty then
                DMTReplacement.DeleteAll();
        end;
    end;

    trigger OnRename()
    begin
    end;

    internal procedure GetCaption(FieldNo: Integer) FieldCaption: Text
    var
        ReplacementHeader, ReplacementLine : Record DMTReplacement;
        CurrentFilter: Text;
        CustomFieldCaption: Text;
    begin
        // GetPagePartFilter
        ReplacementLine.Copy(Rec);
        ReplacementLine.FilterGroup(4);
        CurrentFilter := ReplacementLine.GetFilter("Replacement Code");
        if CurrentFilter in [''/*Not loaded*/, ''''''/*New header Record with empty code*/] then
            exit('');
        if not ReplacementHeader.Get(ReplacementHeader.LineType::Header, ReplacementLine."Replacement Code") then
            exit;

        case FieldNo of
            Rec.FieldNo("Comp.Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("Comp.Value 1");
                    CustomFieldCaption := ReplacementHeader."Comp.Val.1 Caption";
                end;
            Rec.FieldNo("Comp.Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("Comp.Value 2");
                    CustomFieldCaption := ReplacementHeader."Comp.Val.2 Caption";

                end;
            Rec.FieldNo("New Value 1"):
                begin
                    FieldCaption := Rec.FieldCaption("New Value 1");
                    CustomFieldCaption := ReplacementHeader."New Value 1 Caption";
                end;
            Rec.FieldNo("New Value 2"):
                begin
                    FieldCaption := Rec.FieldCaption("New Value 2");
                    CustomFieldCaption := ReplacementHeader."New Value 2 Caption";
                end;
        end;
        if CustomFieldCaption <> '' then
            exit('3,' + CustomFieldCaption)
        else
            exit('3,' + FieldCaption);
    end;

    internal procedure getRelatedTableIDsFilter() Filter: Text
    begin
        if Rec."Rel.to Table ID (New Val.1)" <> 0 then
            Filter += '|' + Format(Rec."Rel.to Table ID (New Val.1)");
        if Rec."Rel.to Table ID (New Val.2)" <> 0 then
            Filter += '|' + Format(Rec."Rel.to Table ID (New Val.2)");
        Filter := Filter.TrimStart('|');
    end;

    procedure filterAssignmentFor(DataFile: Record DMTDataFile) HasLines: Boolean;
    begin
        Rec.SetRange(LineType, LineType::Assignment);
        Rec.SetRange("Data File ID", DataFile.ID);
        Rec.SetRange("Target Table ID", DataFile."Target Table ID");
        HasLines := not Rec.IsEmpty;
    end;

    procedure IsEqual(DMTReplacement: Record DMTReplacement): Boolean
    begin
        exit(format(Rec) = format(DMTReplacement));
    end;
}