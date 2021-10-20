page 91007 FileBrowser
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = File;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                field(CurrFolder; CurrFolder)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.SetRange(Path, CurrFolder);
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Entries)
            {
                Editable = false;
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                    ApplicationArea = All;
                }
                field("Is a file"; Rec."Is a file")
                {
                    ToolTip = 'Specifies the value of the Is a file field.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        if not "Is a file" then begin
                            CurrFolder := CurrFolder + '\' + Rec.Name;
                            CurrFolder := CurrFolder.Replace('\\', '\');
                            Rec.SetRange(Path, CurrFolder);
                            CurrPage.Update();
                        end;

                    end;
                }
                field(Path; Rec.Path)
                {
                    ToolTip = 'Specifies the value of the Path field.';
                    ApplicationArea = All;
                }
                field(Size; Rec.Size)
                {
                    ToolTip = 'Specifies the value of the Size field.';
                    ApplicationArea = All;
                }
                field("Time"; Rec."Time")
                {
                    ToolTip = 'Specifies the value of the Time field.';
                    ApplicationArea = All;
                }
            }
        }
    }


    trigger OnOpenPage()
    begin
        if CurrFolder = '' then
            Rec.SetRange(Path, 'C:\');

    end;

    var
        CurrFolder: Text;
}