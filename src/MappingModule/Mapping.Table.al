table 110038 DMTMapping
{
    Caption = 'DMT Mapping';
    LookupPageId = DMTMappingList;
    DrillDownPageId = DMTMappingList;
    fields
    {
        field(1; Code; Code[100]) { Caption = 'Code'; }
        field(2; Description; Text[250]) { Caption = 'Description'; }
        field(10; "No. of Orginal Fields"; Option)
        {
            Caption = 'No. of Orginal Fields';
            OptionMembers = "1","2","3","4";
            OptionCaption = '1,2,3,4';
        }
        field(11; "Original Value 1 Caption"; Text[80]) { Caption = 'Original Value 1 Caption', Comment = 'Urspr. Wert 1 Bezeichnung'; }
        field(12; "Original Value 2 Caption"; Text[80]) { Caption = 'Original Value 2 Caption', Comment = 'Urspr. Wert 2 Bezeichnung'; }
        field(20; "No. of Mapping Fields"; Option)
        {
            Caption = 'No. of Mapping Fields';
            OptionMembers = "1","2","3","4";
            OptionCaption = '1,2,3,4';
        }
        field(21; "Mapping Value 1 Caption"; Text[80]) { Caption = 'Mapping Value 1 Caption'; }
        field(22; "Mapping Value 2 Caption"; Text[80]) { Caption = 'Mapping Value 2 Caption'; }
    }

    keys
    {
        key(Key1; Code) { Clustered = true; }
    }
}