page 110017 "DMTProcessInstructionFactBox"
{
    Caption = 'Processing Instructions';
    PageType = ListPart;
    SourceTable = DMTFieldMapping;
    SourceTableTemporary = true;
    layout
    {
        area(content)
        {

            field(Edit; 'Edit')
            {
                ApplicationArea = All;
                ShowCaption = false;
                trigger OnDrillDown()
                begin
                    if IsSourceTableFilterView then
                        CurrProcessingPlan.EditSourceTableFilter();
                    CurrPage.Update(false);
                end;
            }
            repeater("FilterList")
            {
                Caption = 'Filter', Comment = 'Filter';
                Visible = IsSourceTableFilterView;
                field("FieldCaption"; Rec."Source Field Caption") { ApplicationArea = All; }
                field(FixedValue; Rec.Comment) { ApplicationArea = All; }
            }

            repeater("FixedValuesList")
            {
                Caption = 'Fixed Values';
                Visible = IsFixedValueView;
                field(FilterFieldCaption; Rec."Source Field Caption") { ApplicationArea = All; }
                field(FilterValue; Rec.Comment) { ApplicationArea = All; Caption = 'Filter'; }

            }
        }
    }

    internal procedure InitFactBoxAsSourceTableFilter(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTFieldMapping: Record DMTFieldMapping;
    begin
        if ProcessingPlan.Type = ProcessingPlan.Type::Group then begin
            IsSourceTableFilterView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsSourceTableFilterView := true;
        DMTFieldMapping.SetRange("Data File ID", ProcessingPlan.ID);
        DMTFieldMapping.CopyToTemp(Rec);
        Rec.SetFilter(Comment, '<>''''');
        CurrPage.Update(false);
        CurrProcessingPlan := ProcessingPlan;
    end;

    internal procedure InitFactBoxAsFixedValueView(ProcessingPlan: Record DMTProcessingPlan)
    var
        DMTFieldMapping: Record DMTFieldMapping;
    begin
        if ProcessingPlan.Type = ProcessingPlan.Type::Group then begin
            IsFixedValueView := false;
            Rec.DeleteAll();
            exit;
        end;
        IsFixedValueView := true;
        DMTFieldMapping.SetRange("Data File ID", ProcessingPlan.ID);
        DMTFieldMapping.CopyToTemp(Rec);
        Rec.SetFilter(Comment, '<>''''');
        CurrPage.Update(false);
        CurrProcessingPlan := ProcessingPlan;
    end;

    procedure SaveDefaultValuesToJSONBlob(ProcessingPlan: Record DMTProcessingPlan; var FieldMapping: Record DMTFieldMapping temporary)
    var
        JSONTools: Codeunit DMTJSONTools;
        JArray: JsonArray;
        JText: Text;
    begin
        if FieldMapping.FindSet then
            repeat
                JArray.Add(JSONTools.Rec2Json(FieldMapping));
            until FieldMapping.Next() = 0;
        JArray.WriteTo(JText);
        ProcessingPlan.SaveDefaultValuesConfig(JText);
    end;

    var
        [InDataSet]
        IsSourceTableFilterView, IsFixedValueView : Boolean;
        CurrProcessingPlan: Record DMTProcessingPlan;
}

