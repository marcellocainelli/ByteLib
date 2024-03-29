unit uClienteEmail;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TClienteEmail = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TClienteEmail }

constructor TClienteEmail.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CADCLI_EMAIL where COD_CLI = :pCod_Cli');

  InicializaDataSource;
end;

destructor TClienteEmail.Destroy;
begin
  inherited;
end;

class function TClienteEmail.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteEmail.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteEmail.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('EMAIL');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteEmail.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pCod_Cli', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('EMAIL');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TClienteEmail.ModificaDisplayCampos;
begin

end;

function TClienteEmail.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
