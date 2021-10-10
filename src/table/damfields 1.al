page 90003 damfields
{

    ApplicationArea = All;
    Caption = 'damfields';
    PageType = List;
    SourceTable = DAMFieldBuffer;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Class; Rec.Class)
                {
                    ToolTip = 'Specifies the value of the Class field.';
                    ApplicationArea = All;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies the value of the Enabled field.';
                    ApplicationArea = All;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ToolTip = 'Specifies the value of the Field Caption field.';
                    ApplicationArea = All;
                }
                field(FieldName; Rec.FieldName)
                {
                    ToolTip = 'Specifies the value of the FieldName field.';
                    ApplicationArea = All;
                }
                field(Len; Rec.Len)
                {
                    ToolTip = 'Specifies the value of the Len field.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                }
                field(RelationFieldNo; Rec.RelationFieldNo)
                {
                    ToolTip = 'Specifies the value of the RelationFieldNo field.';
                    ApplicationArea = All;
                }
                field(RelationTableNo; Rec.RelationTableNo)
                {
                    ToolTip = 'Specifies the value of the RelationTableNo field.';
                    ApplicationArea = All;
                }
                field(SQLDataType; Rec.SQLDataType)
                {
                    ToolTip = 'Specifies the value of the SQLDataType field.';
                    ApplicationArea = All;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ToolTip = 'Specifies the value of the Table Caption field.';
                    ApplicationArea = All;
                }
                field(TableName; Rec.TableName)
                {
                    ToolTip = 'Specifies the value of the TableName field.';
                    ApplicationArea = All;
                }
                field(TableNo; Rec.TableNo)
                {
                    ToolTip = 'Specifies the value of the TableNo field.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                }
                field("Type Name"; Rec."Type Name")
                {
                    ToolTip = 'Specifies the value of the Type Name field.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
