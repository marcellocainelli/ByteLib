unit uNaturezaSubClasse;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TNaturezaSubClasse = class(TInterfacedObject, iEntidade)
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

{ TNaturezaSubClasse }

constructor TNaturezaSubClasse.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NATUREZA_SUBCLASSE '+
                         'where cod_natureza_classe = :pCodNaturezaClasse');

  InicializaDataSource;
end;

destructor TNaturezaSubClasse.Destroy;
begin

  inherited;
end;

class function TNaturezaSubClasse.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNaturezaSubClasse.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNaturezaSubClasse.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('HISTORICO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNaturezaSubClasse.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From NATUREZA_SUBCLASSE Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNaturezaSubClasse.ModificaDisplayCampos;
begin

end;

function TNaturezaSubClasse.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
