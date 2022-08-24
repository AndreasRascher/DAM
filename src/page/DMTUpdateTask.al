page 110024 "DMTUpdateTask"
{
    PageType = Worksheet;
    UsageCategory = None;
    SourceTable = DMTField;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                // field(Name; NameSource)
                // {
                //     ApplicationArea = All;

                // }
            }
            repeater(SelectedFields)
            {
                field("To Field No."; Rec."Target Field No.") { ApplicationArea = All; Editable = false; }
                field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; Editable = false; }
                field(Selected; IsSelected)
                {
                    ApplicationArea = All;
                    Caption = 'Update';
                    trigger OnValidate()
                    begin
                        if rec."Target Field No." = 0 then
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

    procedure GetToFieldNoFilter() ToFieldNoFilter: text
    var
        DMTMgt: Codeunit DMTMgt;
        ToFieldNo: Integer;
        KeyFieldFilter: text;
    begin

        // Collect Key Field IDs
        KeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDMTTable."Target Table ID", true /*include*/);
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

    procedure InitFieldSelection(DMTTable: record DMTTable) OK: Boolean
    var
        Field: Record DMTField;
        DMTMgt: Codeunit DMTMgt;
        NonKeyFieldFilter: Text;
    begin
        OK := true;
        CurrDMTTable.copy(DMTTable);
        if CurrDMTTable."Target Table ID" = 0 then
            exit(false);

        // Filter Fields Avaible for Update
        Rec.FilterGroup(2);
        Rec.SetRange("Target Table ID", CurrDMTTable."Target Table ID");
        Rec.Setfilter("Processing Action", '<>%1', Field."Processing Action"::Ignore);
        Rec.SetFilter("Source Field No.", '<>%1', 0);
        NonKeyFieldFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(CurrDMTTable."Target Table ID", false /*exclude*/);
        Rec.Setfilter("Target Field No.", NonKeyFieldFilter);
        // restore last selection
        if DMTTable.ReadLastFieldUpdateSelection() <> '' then begin
            SelectedFields := ConvertNumberFilterToNumberList(DMTTable.ReadLastFieldUpdateSelection());
        end;
    end;

    procedure ConvertNumberFilterToNumberList(NumberFilter: Text) NumberList: List of [Integer]
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

    var
        CurrDMTTable: record DMTTable;
        [InDataSet]
        IsSelected: Boolean;
        KeyFields: List of [Integer];
        SelectedFields: List of [Integer];
}