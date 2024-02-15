unit uClientePacotes;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TClientePacotes = class(TInterfacedObject, iEntidade)
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

{ TClientePacotes }

constructor TClientePacotes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select cp.*, p.nome_prod ' +
    'from CADCLI_PACOTES cp ' +
    'join produtos p on (p.cod_prod = cp.cod_prod) ' +
    'where cp.cod_cli = :pCod_Cli and ((cp.cod_animal = :pCod_Animal) or (:pCod_Animal = -1)) ');
  InicializaDataSource;
end;

destructor TClientePacotes.Destroy;
begin
  inherited;
end;

class function TClientePacotes.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClientePacotes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClientePacotes.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('COD_CLI');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClientePacotes.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From CADCLI_PACOTES Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TClientePacotes.ModificaDisplayCampos;
begin

end;

function TClientePacotes.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
