unit uConfig_DoutorByte;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TConfig_DoutorByte = class(TInterfacedObject, iEntidade)
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

{ TBrindes }

constructor TConfig_DoutorByte.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from CONFIG_DOUTORBYTE WHERE ID = 1 ');

  InicializaDataSource;
end;

destructor TConfig_DoutorByte.Destroy;
begin
  inherited;
end;

class function TConfig_DoutorByte.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfig_DoutorByte.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfig_DoutorByte.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfig_DoutorByte.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CONFIG_DOUTORBYTE Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfig_DoutorByte.ModificaDisplayCampos;
begin
end;

function TConfig_DoutorByte.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
