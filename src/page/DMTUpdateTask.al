page 110003 "DMTUpdateTask"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTField;
    ModifyAllowed = false;
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
                field("To Field No."; Rec."To Field No.") { ApplicationArea = All; }
                field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; }
                field(Selected; IsSelected)
                {
                    ApplicationArea = All;
                    Caption = 'Update';
                    trigger OnValidate()
                    begin
                        if rec."To Field No." = 0 then
                            exit;
                        if IsSelected then begin
                            if not SelectedRecords.Contains(Rec."To Field No.") then
                                SelectedRecords.Add(Rec."To Field No.");
                        end else begin
                            if SelectedRecords.Contains(Rec."To Field No.") then
                                SelectedRecords.Remove(Rec."To Field No.");
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsSelected := SelectedRecords.Contains(Rec."To Field No.");
    end;

    procedure GetToFieldNoFilter() ToFieldNoFilter: text
    var
        ToFieldNo: Integer;
    begin
        if SelectedRecords.Count = 0 then
            exit('');
        foreach ToFieldNo in SelectedRecords do begin
            ToFieldNoFilter += StrSubstNo('%1|', ToFieldNo);
        end;
        ToFieldNoFilter := ToFieldNoFilter.TrimEnd('|');
    end;

    procedure SetToFieldNoFilter(ToFieldNoFilter: text)
    var
        Integer: Record Integer;
    begin
        if ToFieldNoFilter = '' then
            exit;
        Integer.SetFilter(Number, ToFieldNoFilter);
        Integer.FindSet();
        repeat
            SelectedRecords.Add(Integer.Number);
        until Integer.Next() = 0;
    end;

    var
        [InDataSet]
        IsSelected: Boolean;
        SelectedRecords: List of [Integer];
}