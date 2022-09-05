unit uPosto_BombasLacres;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPosto_BombasLacres = class(TInterfacedObject, iEntidade)
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

{ TPosto_BombasLacres }

constructor TPosto_BombasLacres.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from BOMBAS_LACRES where COD_FILIAL = :pCod_Filial and COD_BOMBA = :pCod_Bomba');
  InicializaDataSource;
end;

destructor TPosto_BombasLacres.Destroy;
begin
  inherited;
end;

class function TPosto_BombasLacres.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_BombasLacres.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_BombasLacres.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('COD_BOMBA');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPosto_BombasLacres.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'select * from BOMBAS_LACRES Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_BombasLacres.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DT_APLICACAO')).EditMask:= '!99/99/00;1;_';
end;

function TPosto_BombasLacres.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
