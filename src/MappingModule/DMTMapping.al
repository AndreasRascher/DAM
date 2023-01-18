table 110011 DMTMapping
{
    fields
    {
        field(1; Code; Code[100]) { Caption = 'Code'; }
        field(10; Description; Text[250]) { Caption = 'Description'; }
    }

    keys
    {
        key(Key1; Code) { Clustered = true; }
    }
}