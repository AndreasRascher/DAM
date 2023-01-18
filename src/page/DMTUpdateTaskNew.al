page 110029 DMTUpdateTaskNew
{
    PageType = Worksheet;
    UsageCategory = None;
    SourceTable = DMTFieldMapping;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(SelectedFieldsList; GetSelectedFieldsList()) { ApplicationArea = All; Caption = 'Current Selection'; }
            }
            repeater(SelectedFields)
            {
                Caption = 'Select Fields';
                field("To Field No."; Rec."Target Field No.") { ApplicationArea = All; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; Editable = false; }
                field(Selected; IsSelected)
                {
                    Caption = 'Update';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Rec."Target Field No." = 0 then
                            exit;
                        if IsSelected then begin
                            if not SelectedFields.Contains(Rec."Target Field No.") then
                                SelectedFields.Add(Rec."Target Field No.");
                        end else begin
                            if SelectedFields.Contains(Rec."Target Field No.") then
                                SelectedFields.Remove(Rec."Target Field No.");
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsSelected := SelectedFields.Contains(Rec."Target Field No.");
    end;

    procedure GetToFieldNoFilter() ToFieldNoFilter: Text
    var
        DMTMgt: Codeunit DMTMgt;
        ToFieldNo: Integer;
        KeyFieldFilter: Text;
    begin

        // Collect Key Field IDs
        KeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDataFile."Target Table ID", true /*include*/);
        KeyFields := ConvertNumberFilterToNumberList(KeyFieldFilter);
        foreach ToFieldNo in KeyFields do begin
            ToFieldNoFilter += StrSubstNo('%1|', ToFieldNo);
        end;

        // Collect selected Field ID's
        if SelectedFields.Count = 0 then
            exit('');
        foreach ToFieldNo in SelectedFields do begin
            ToFieldNoFilter += StrSubstNo('%1|', ToFieldNo);
        end;

        ToFieldNoFilter := ToFieldNoFilter.TrimEnd('|');
    end;

    procedure InitFieldSelection(DataFile: Record DMTDataFile) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
        DMTMgt: Codeunit DMTMgt;
        NonKeyFieldFilter: Text;
    begin
        OK := true;
        CurrDataFile.Copy(DataFile);
        if CurrDataFile."Target Table ID" = 0 then
            exit(false);

        // Filter Fields Avaible for Update
        Rec.FilterGroup(2);
        Rec.SetRange("Target Table ID", CurrDataFile."Target Table ID");
        Rec.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        Rec.SetFilter("Source Field No.", '<>%1', 0);
        NonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDataFile."Target Table ID", false /*exclude*/);
        Rec.SetFilter("Target Field No.", NonKeyFieldFilter);
        // restore last selection
        if DataFile.ReadLastFieldUpdateSelection() <> '' then begin
            SelectedFields := ConvertNumberFilterToNumberList(DataFile.ReadLastFieldUpdateSelection());
        end;
    end;

    procedure InitFieldSelection(ProcessingPlan: Record DMTProcessingPlan) OK: Boolean
    var
        FieldMapping: Record DMTFieldMapping;
        DMTMgt: Codeunit DMTMgt;
        NonKeyFieldFilter: Text;
    begin
        OK := true;
        CurrDataFile.Get(ProcessingPlan.ID);
        if CurrDataFile."Target Table ID" = 0 then
            exit(false);

        // Filter Fields Avaible for Update
        Rec.FilterGroup(2);
        Rec.SetRange("Target Table ID", CurrDataFile."Target Table ID");
        Rec.SetFilter("Processing Action", '<>%1', FieldMapping."Processing Action"::Ignore);
        Rec.SetFilter("Source Field No.", '<>%1', 0);
        NonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDataFile."Target Table ID", false /*exclude*/);
        Rec.SetFilter("Target Field No.", NonKeyFieldFilter);
        // restore last selection
        if ProcessingPlan.ReadUpdateFieldsFilter() <> '' then begin
            SelectedFields := ConvertNumberFilterToNumberList(ProcessingPlan.ReadUpdateFieldsFilter());
        end;
    end;

    local procedure ConvertNumberFilterToNumberList(NumberFilter: Text) NumberList: List of [Integer]
    var
        Integer: Record Integer;
    begin
        if NumberFilter = '' then exit;
        Integer.SetFilter(Number, NumberFilter);
        Integer.FindSet();
        repeat
            NumberList.Add(Integer.Number);
        until Integer.Next() = 0;
    end;

    local procedure GetSelectedFieldsList() FieldsListAsText: Text
    var
        ID: Integer;
        FieldMapping: Record DMTFieldMapping;
    begin
        foreach ID in SelectedFields do begin
            FieldMapping.Get(CurrDataFile.ID, ID);
            FieldMapping.Calcfields("Target Field Caption");
            FieldsListAsText += ', ' + FieldMapping."Target Field Caption";
        end;
        FieldsListAsText := FieldsListAsText.TrimStart(', ');
    end;

    var
        CurrDataFile: Record DMTDataFile;
        [InDataSet]
        IsSelected: Boolean;
        KeyFields: List of [Integer];
        SelectedFields: List of [Integer];
}