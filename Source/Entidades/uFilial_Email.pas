unit uFilial_Email;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TFilial_Email = class(TInterfacedObject, iEntidade)
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

{ TFilial_Email }

constructor TFilial_Email.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select FE.*, 0 as INDICE From FILIAL_EMAIL FE');
  InicializaDataSource;
end;

destructor TFilial_Email.Destroy;
begin
  inherited;
end;

class function TFilial_Email.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TFilial_Email.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFilial_Email.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL + ' Where FE.ID = :pCodFilial';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFilial_Email.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFilial_Email.ModificaDisplayCampos;
begin

end;

function TFilial_Email.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
