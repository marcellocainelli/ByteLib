unit uPosto_LmcTanque;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPosto_LmcTanque = class(TInterfacedObject, iEntidade)
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

{ TPosto_LmcTanque }

constructor TPosto_LmcTanque.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select l.*, p.nome_prod as combustivel ' +
    'from LMCTANQUE l ' +
    'join tanque t on (t.cod_filial = l.cod_filial) and (t.cod_tanque = l.cod_tanque) ' +
    'join produtos p on (p.cod_prod = t.cod_prod) ' +
    'Where SEQ = :SEQ');
  InicializaDataSource;
end;

destructor TPosto_LmcTanque.Destroy;
begin
  inherited;
end;

class function TPosto_LmcTanque.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_LmcTanque.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_LmcTanque.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'COMBUSTIVEL', False);
end;

function TPosto_LmcTanque.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From LMCTANQUE Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_LmcTanque.ModificaDisplayCampos;
begin

end;

function TPosto_LmcTanque.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
