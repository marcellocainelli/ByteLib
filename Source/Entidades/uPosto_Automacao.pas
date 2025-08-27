unit uPosto_Automacao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TPosto_Automacao = class(TInterfacedObject, iEntidade)
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

{ TBanco }

constructor TPosto_Automacao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from AUTOMACAO Where COD_FILIAL = :PCod_Filial and BAIXADO = ''X'' ');
  InicializaDataSource;
end;

destructor TPosto_Automacao.Destroy;
begin
  inherited;
end;

class function TPosto_Automacao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_Automacao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_Automacao.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPosto_Automacao.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from AUTOMACAO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_Automacao.ModificaDisplayCampos;
begin

end;

function TPosto_Automacao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
