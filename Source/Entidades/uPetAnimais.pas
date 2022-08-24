unit uPetAnimais;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPetAnimais = class(TInterfacedObject, iEntidade)
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

{ TPetAnimais }

constructor TPetAnimais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from PET_ANIMAIS where COD_CLIENTE = :pCod_Cliente ');
  InicializaDataSource;
end;

destructor TPetAnimais.Destroy;
begin
  inherited;
end;

class function TPetAnimais.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetAnimais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetAnimais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetAnimais.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= 'Select * from PET_ANIMAIS where (1 <> 1) ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPetAnimais.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DT_NASCIMENTO')).EditMask:= '!99/99/00;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PESO')).DisplayFormat:= '#####0.00';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DT_CADASTRO')).EditMask:= '!99/99/00;1;_';
end;

function TPetAnimais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
