page 110029 "DMTSelectMultipleFields"
{
    Caption = 'Select multiple fields';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTFieldMapping;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    SourceTableTemporary = true;
    LinksAllowed = false;
    DataCaptionExpression = SelectedFieldsCaption;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(SelectedFieldsList; SelectedFieldsCaption) { ApplicationArea = All; Caption = 'Current Selection'; Editable = false; }
            }
            repeater(SelectedFields)
            {
                Caption = 'Select Fields';
                field("Target Field No."; Rec."Target Field No.") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Target Field Name"; Rec."Target Field Name") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Target Field Caption"; Rec."Search Target Field Caption") { ApplicationArea = All; Editable = false; Visible = ShowTargetFieldInfo; }
                field("Source Field No."; Rec."Source Field No.") { ApplicationArea = All; Editable = false; Visible = ShowSourceFieldInfo; }
                field("Source Field Caption"; Rec."Source Field Caption") { ApplicationArea = All; Editable = false; Visible = ShowSourceFieldInfo; }
                field(Selection; Rec.Selection)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.Modify();
                        RefreshSelectedFieldsCaption();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RefreshSelectedFieldsCaption();
    end;

    procedure GetTargetFieldIDListAsText() TargetFieldIDListAsText: Text
    var
        FieldIDList: List of [Integer];
        TargetFieldCaptionListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetTargetFieldCaptionListAsText() TargetFieldCaptionListAsText: Text
    var
        FieldIDList: List of [Integer];
        TargetFieldIDListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetTargetFieldIDList() FieldIDList: List of [Integer]
    var
        TargetFieldCaptionListAsText: Text;
        TargetFieldIDListAsText: Text;
    begin
        GetToFieldListInner(Rec, FieldIDList, TargetFieldCaptionListAsText, TargetFieldIDListAsText);
    end;

    procedure GetSelectedSourceFieldIDList() FieldIDList: List of [Integer];
    var
        TempFieldMapping: Record DMTFieldMapping temporary;
    begin
        TempFieldMapping.Copy(Rec, true);
        TempFieldMapping.Reset();
        TempFieldMapping.Setrange(Selection, true);
        if TempFieldMapping.FindSet() then
            repeat
                FieldIDList.Add(TempFieldMapping."Source Field No.");
            until TempFieldMapping.Next() = 0;
    end;

    local procedure GetToFieldListInner(var FieldMapping_REC: Record DMTFieldMapping temporary; var FieldIDList: List of [Integer]; var TargetFieldCaptionListAsText: Text; var TargetFieldIDListAsText: Text)
    var
        TempFieldMapping: Record DMTFieldMapping temporary;
    begin
        Clear(FieldIDList);
        Clear(TargetFieldCaptionListAsText);
        Clear(TargetFieldIDListAsText);
        TempFieldMapping.Copy(FieldMapping_REC, true);
        TempFieldMapping.Reset();
        TempFieldMapping.Setrange(Selection, true);
        if TempFieldMapping.FindSet() then
            repeat
                FieldIDList.Add(TempFieldMapping."Target Field No.");
                TargetFieldIDListAsText += StrSubstNo('%1|', TempFieldMapping."Target Field No.");
                TempFieldMapping.CalcFields("Target Field Caption");
                TargetFieldCaptionListAsText += StrSubstNo('%1|', TempFieldMapping."Target Field Caption");
            until TempFieldMapping.Next() = 0;
        TargetFieldIDListAsText := TargetFieldIDListAsText.TrimEnd('|');
        TargetFieldCaptionListAsText := TargetFieldCaptionListAsText.TrimEnd('|');
    end;

    procedure InitSelectTargetFields(DataFile: Record DMTDataFile; SelectedTargetFieldIDFilter: Text) OK: Boolean
    begin
        ShowTargetFieldInfo := true;
        OK := true;
        if not LoadFieldMapping(Rec, DataFile.ID) then
            exit(false);
        if SelectedTargetFieldIDFilter <> '' then
            RestoreTargetSelection(SelectedTargetFieldIDFilter);
    end;

    procedure InitSelectTargetFields(ProcessingPlan: Record DMTProcessingPlan) OK: Boolean
    var
        DMTMgt: Codeunit DMTMgt;
        TargetFieldFilter: Text;
    begin
        OK := true;
        ShowTargetFieldInfo := true;
        TargetFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDataFile."Target Table ID", false /*exclude*/);
        if not LoadFieldMapping(Rec, ProcessingPlan.ID) then
            exit(false);

        Rec.SetFilter("Target Field No.", TargetFieldFilter);
        // restore last selection
        if ProcessingPlan.ReadUpdateFieldsFilter() <> '' then begin
            RestoreTargetSelection(ProcessingPlan.ReadUpdateFieldsFilter());
        end;
    end;

    procedure InitSelectSourceFields(DataFile: Record DMTDataFile; SelectedSourceFieldIDFilter: Text) OK: Boolean
    begin
        OK := true;
        ShowSourceFieldInfo := true;
        if not LoadFieldMapping(Rec, DataFile.ID) then
            exit(false);
        RestoreSourceSelection(SelectedSourceFieldIDFilter);
    end;

    local procedure LoadFieldMapping(var TempFieldMapping: Record DMTFieldMapping temporary; DataFieldID: Integer) Success: Boolean
    var
        DataFile: Record DMTDataFile;
        FieldMapping: Record DMTFieldMapping;
    begin
        if not DataFile.Get(DataFieldID) then
            exit(false);
        if DataFile."Target Table ID" = 0 then
            exit(false);

        DataFile.FilterRelated(FieldMapping);
        FieldMapping.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        FieldMapping.SetFilter("Source Field No.", '<>%1', 0);
        FieldMapping.SetRange("Is Key Field(Target)", false);
        FieldMapping.CopyToTemp(TempFieldMapping);
        Success := not TempFieldMapping.IsEmpty();
    end;

    local procedure RestoreSourceSelection(SelectedFieldNoFilter: Text)
    begin
        if SelectedFieldNoFilter = '' then
            exit;
        Rec.Reset();
        Rec.SetFilter("Source Field No.", SelectedFieldNoFilter);
        if Rec.FindSet(false, false) then
            repeat
                Rec.Selection := true;
                Rec.Modify();
            until Rec.Next() = 0;
        Rec.Reset();
    end;

    local procedure RestoreTargetSelection(SelectedFieldNoFilter: Text)
    begin
        if SelectedFieldNoFilter = '' then
            exit;
        Rec.Reset();
        Rec.SetFilter("Target Field No.", SelectedFieldNoFilter);
        if Rec.FindSet(false, false) then
            repeat
                Rec.Selection := true;
                Rec.Modify();
            until Rec.Next() = 0;
        Rec.Reset();
    end;

    procedure RefreshSelectedFieldsCaption()
    begin
        SelectedFieldsCaption := GetTargetFieldCaptionListAsText();
    end;

    var
        CurrDataFile: Record DMTDataFile;
        SelectedFieldsCaption: Text;

        [InDataSet]
        ShowSourceFieldInfo, ShowTargetFieldInfo : Boolean;
}