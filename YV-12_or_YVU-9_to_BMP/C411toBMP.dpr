program C411toBMP;

uses
  Forms,
  Screen411toBMP in 'Screen411toBMP.pas' {Form411toBMP};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm411toBMP, Form411toBMP);
  Application.Run;
end.
