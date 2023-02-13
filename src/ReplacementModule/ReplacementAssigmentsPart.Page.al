page 110030 DMTReplacementAssigmentsPart
{
    Caption = 'Replacements';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = DMTReplacement;
    // AutoSplitKey = true;
    SourceTableView = where(LineType = const(Assignment));
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            // field(IsDataFileVisible; IsDataFileVisible) { ApplicationArea = All; }
            repeater(AssignmentPerDataFile)
            {
                Visible = IsAssignmentPerDataFile;
                // field(IsAssignmentPerDataFile; IsAssignmentPerDataFile) { ApplicationArea = All; }
                field("Replacement Code"; Rec."Replacement Code") { ApplicationArea = All; }
                field(Comparefields; GetCompareFieldsList())
                {
                    Caption = 'Compare Fields';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        OnDrillDownCompareFields();
                    end;
                }
                field(NewValueFields; GetNewValueFieldsList())
                {
                    Caption = 'New Value Fields';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        OnDrillDownNewValueFields();
                    end;
                }
            }
            repeater(AssignmentPerReplacement)
            {
                Visible = IsAssignmentPerReplacement;
                // field(IsAssignmentPerReplacement; IsAssignmentPerReplacement) { ApplicationArea = All; }

                field(Overview_DataFileName; Rec."Data File Name") { ApplicationArea = All; }
                field(Overview_DataFileID; Rec."Data File ID") { ApplicationArea = All; }
                field(Overview_ReplacementCode; Rec."Replacement Code") { ApplicationArea = All; TableRelation = DMTReplacement."Replacement Code" where(LineType = const(Header)); }
                field(Overview_Comparefields; GetCompareFieldsList())
                {
                    Caption = 'Compare Fields';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        OnDrillDownCompareFields();
                    end;
                }
                field(Overview_NewValueFields; GetNewValueFieldsList())
                {
                    Caption = 'New Value Fields';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        OnDrillDownNewValueFields();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(Toggle)
            // {
            //     Caption = 'Update';
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     begin
            //         CurrPage.Update();
            //     end;
            // }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.FilterGroup(4);
        if Rec."Data File ID" = 0 then
            if Rec.GetFilter("Data File ID") <> '' then
                Rec."Data File ID" := Rec.GetRangeMin("Data File ID");
        if Rec."Target Table ID" = 0 then
            if Rec.GetFilter("Target Table ID") <> '' then
                Rec."Target Table ID" := Rec.GetRangeMin("Target Table ID");
        Rec.FilterGroup(0);
    end;

    internal procedure GetCompareFieldsList() returnText: Text
    var
        FieldMapping: Record DMTFieldMapping;
        ClickToEditLbl: Label '<Click to Edit>';
    begin
        if Rec."Replacement Code" = '' then exit('');
        FieldMapping.SetRange("Data File ID", Rec."Data File ID");
        FieldMapping.SetFilter("Source Field No.", '%1|%2', Rec."Compare Value 1 Field No.", Rec."Compare Value 2 Field No.");
        FieldMapping.FilterGroup(2);
        FieldMapping.SetFilter("Source Field No.", '<>0');
        FieldMapping.FilterGroup(0);
        if not FieldMapping.FindSet(false, false) then
            exit(ClickToEditLbl);
        repeat
            returnText += ',' + FieldMapping."Source Field Caption";
        until FieldMapping.Next() = 0;
        returnText := returnText.TrimStart(',');
        if returnText = '' then
            returnText := ClickToEditLbl;
    end;

    local procedure GetNewValueFieldsList() returnText: Text
    var
        fieldMapping: Record DMTFieldMapping;
        ClickToEditLbl: Label '<Click to Edit>';
    begin
        if Rec."Replacement Code" = '' then exit('');
        FieldMapping.SetRange("Data File ID", Rec."Data File ID");
        FieldMapping.SetFilter("Target Field No.", '%1|%2', Rec."New Value 1 Field No.", Rec."New Value 2 Field No.");
        if not FieldMapping.FindSet(false, false) then
            exit(ClickToEditLbl);
        repeat
            fieldMapping.CalcFields("Target Field Caption");
            returnText += ',' + FieldMapping."Target Field Caption";
        until FieldMapping.Next() = 0;
        returnText := returnText.TrimStart(',');
        if returnText = '' then
            returnText := ClickToEditLbl;
    end;

    internal procedure EditCompareFieldsList()
    var
        DataFile: Record DMTDataFile;
        SelectMultipleFields: Page DMTSelectMultipleFields;
        SelectedFields: List of [Integer];
        i: Integer;
        RunModalAction: Action;
    begin
        if not DataFile.Get(Rec."Data File ID") then exit;
        SelectMultipleFields.InitSelectSourceFields(DataFile, StrSubstNo('%1|%2', Rec."Compare Value 1 Field No.", Rec."Compare Value 2 Field No."));
        // SelectMultipleFields.LookupMode(true);
        RunModalAction := SelectMultipleFields.RunModal();
        if RunModalAction = Action::OK then begin
            SelectedFields := SelectMultipleFields.GetSelectedSourceFieldIDList();
            Clear(Rec."Compare Value 1 Field No.");
            Clear(Rec."Compare Value 2 Field No.");
            for i := 1 to SelectedFields.Count do begin
                case true of
                    (i = 1):
                        Rec."Compare Value 1 Field No." := SelectedFields.Get(i);
                    (i = 2):
                        Rec."Compare Value 2 Field No." := SelectedFields.Get(i);
                end;
            end;
            Rec.Modify();
        end;
    end;

    local procedure EditNewValueFieldsList()
    var
        DataFile: Record DMTDataFile;
        SelectMultipleFields: Page DMTSelectMultipleFields;
        SelectedFields: List of [Integer];
        i: Integer;
        RunModalAction: Action;
    begin
        if not DataFile.Get(Rec."Data File ID") then exit;
        SelectMultipleFields.InitSelectTargetFields(DataFile, StrSubstNo('%1|%2', Rec."New Value 1 Field No.", Rec."New Value 2 Field No."));
        // SelectMultipleFields.LookupMode(true);
        SelectMultipleFields.Editable := true;
        RunModalAction := SelectMultipleFields.RunModal();
        if RunModalAction = Action::OK then begin
            SelectedFields := SelectMultipleFields.GetTargetFieldIDList();
            Clear(Rec."New Value 1 Field No.");
            Clear(Rec."New Value 2 Field No.");
            for i := 1 to SelectedFields.Count do begin
                case true of
                    (i = 1):
                        Rec."New Value 1 Field No." := SelectedFields.Get(i);
                    (i = 2):
                        Rec."New Value 2 Field No." := SelectedFields.Get(i);
                end;
            end;
            Rec.Modify();
        end;
    end;

    /// <summary>
    /// After selecting the compary fields, propose the targetfields assigned in the field mapping
    /// </summary>
    local procedure IfTargetFieldsEmptyPopulateWithCompareFields()
    var
        replacementHeader: Record DMTReplacement;
    begin
        rec.TestField(LineType, rec.LineType::Assignment);

        replacementHeader.Get(rec.LineType::Header, Rec."Replacement Code", 0);
        if replacementHeader."No. of Compare Values" = replacementHeader."No. of Values to modify" then begin
            case replacementHeader."No. of Compare Values" of
                replacementHeader."No. of Compare Values"::"1":
                    begin
                        if Rec."New Value 1 Field No." = 0 then
                            Rec."New Value 1 Field No." := FindTargetFieldByCompareField(Rec."Data File ID", Rec."Compare Value 1 Field No.");
                    end;

                replacementHeader."No. of Compare Values"::"2":
                    begin
                        if Rec."New Value 1 Field No." = 0 then
                            Rec."New Value 1 Field No." := FindTargetFieldByCompareField(Rec."Data File ID", Rec."Compare Value 1 Field No.");
                        if Rec."New Value 2 Field No." = 0 then
                            Rec."New Value 2 Field No." := FindTargetFieldByCompareField(Rec."Data File ID", Rec."Compare Value 2 Field No.");
                    end;
            end;
        end;
    end;

    /// <summary>
    /// Get TargetFieldNo by datafile and source field id
    /// </summary>
    /// <returns>Returns 0 if not found</returns>
    local procedure FindTargetFieldByCompareField(DataFieldID: Integer; SourceFieldNo: Integer) TargetFieldNo: Integer
    var
        fieldMapping: Record DMTFieldMapping;
    begin
        if SourceFieldNo = 0 then
            exit(0);
        fieldMapping.SetRange("Data File ID", DataFieldID);
        fieldMapping.SetRange("Source Field No.", SourceFieldNo);
        if fieldMapping.FindFirst() then
            if fieldMapping.Next() = 0 then
                TargetFieldNo := fieldMapping."Target Field No."
            else
                exit(0);
    end;

    local procedure OnDrillDownCompareFields()
    begin
        if (Rec."Replacement Code" <> '') then
            CurrPage.SaveRecord();
        EditCompareFieldsList();
        IfTargetFieldsEmptyPopulateWithCompareFields();
    end;

    local procedure OnDrillDownNewValueFields()
    begin
        if (Rec."Replacement Code" <> '') then
            CurrPage.SaveRecord();
        EditNewValueFieldsList();
    end;

    procedure InitializeAsAssignmentPerReplacement()
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
        IsAssignmentPerDataFile := false;
        IsAssignmentPerReplacement := true;
        CurrPage.Update();
    end;

    procedure InitializeAsAssignmentPerDataFile()
    begin
        if IsInitialized then
            exit;
        IsAssignmentPerDataFile := true;
        IsAssignmentPerReplacement := false;
        CurrPage.Update();
    end;

    var
        [InDataSet]
        IsAssignmentPerDataFile, IsAssignmentPerReplacement : Boolean;
        IsInitialized: Boolean;
}