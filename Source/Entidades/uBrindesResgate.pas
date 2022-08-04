unit uBrindesResgate;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TBrindesResgate = class(TInterfacedObject, iEntidade)
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

{ TBrindesResgate }

constructor TBrindesResgate.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select BR.*, B.DESCRICAO from BRINDES_RESGATE BR ' +
    'Join BRINDES B On (B.ID = BR.IDBRINDE) ' +
    'Where IDCLIENTE = :pCod_Cli');
  InicializaDataSource;
end;

destructor TBrindesResgate.Destroy;
begin
  inherited;
end;

class function TBrindesResgate.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBrindesResgate.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBrindesResgate.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBrindesResgate.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select BR.*, B.DESCRICAO from BRINDES_RESGATE BR Join BRINDES B On (B.ID = BR.IDBRINDE) Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TBrindesResgate.ModificaDisplayCampos;
begin

end;

function TBrindesResgate.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
