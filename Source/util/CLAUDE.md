# ByteLib — `Source\util` — Guia de Manutenção

> Leia este arquivo ANTES de qualquer alteração na pasta. Ele descreve o que existe, o padrão de código em uso e as armadilhas conhecidas.
> Gerado a partir de leitura (sem alterações no código) em 14/10/2026. Nada aqui foi validado por compilação.

---

## 1. O que é esta pasta

`E:\Prg_DelphiX\ByteLib\Source\util` é a camada de **utilidades e integrações externas** da ByteLib (Delphi, VCL com trechos FMX). São 22 units `.pas`, ~9.150 linhas, sem `.dpr`/`.dpk`/`.dproj` na pasta.

Ponto importante: **o motor de acesso ao Firebird NÃO está nesta pasta.** Aqui ficam apenas os *consumidores* dele. As units abaixo são referenciadas mas vivem em outro diretório da ByteLib (precisam estar no Library Path):

| Unit externa | Papel (inferido pelo uso) |
|---|---|
| `uEntidade`, `Model.Entidade.Interfaces` | `TEntidade` / `iEntidade`: entidade que executa SQL (`EntidadeBase.TextoSQL`, `AddParametro`, `Consulta`, `DtSrc.DataSet`, `EntidadeBase.Iquery.ExecQuery`) |
| `Model.Conexao.Interfaces`, `Controller.Factory.Table` | `iTable` (`Tabela`, `CriaDataSet`) – dataset em memória |
| `uCliente`, `uFilial` | entidades de tabela |
| `Controller.LogError` | log de erros |
| `uMulticlass`, `DTSuperTEF`, `Xml.Reader`, `Xml.Builder` | componentes/bibliotecas de terceiros |
| `RESTRequest4D` | cliente HTTP usado em quase tudo |
| `Dataset.Serialize` | JSON <-> DataSet |
| `AWS.S3`, `AWS.Client` | SDK AWS de terceiros (somente `Byte.AWS.Sdk.S3`) |

**Recomendação:** para auditar o motor Firebird (conexão sob demanda, falhas, melhorias), conectar também a pasta onde estão `uEntidade`, `Model.Conexao.*` e `Controller.Factory.*`.

---

## 2. Catálogo de units

### 2.1 Núcleo (sem dependência de serviço externo)

| Unit | Conteúdo |
|---|---|
| `Byte.Consts` | Constantes `C_EXP_*` (regex de CPF/CNPJ, e-mail, DDD, fone, site, CEP). `C_EXP_RG` e `C_EXP_INSCRICAO` estão vazias. |
| `Byte.Lib` | `TLib`: **só `class function/procedure`**, nunca instanciada. Organizada em `{$REGION}`: Funções úteis (thread, internet, PDF, Extenso, boolean S/N), Formatação (documento, zeros, acento, Pad*), Matemática (`RoundABNT`, `RoundTo2`), Validação (CPF, CNPJ, EAN13, regex via `TTipoValidacao`), Base64, Encriptação (XOR). Também `GetTokenApiProdutos`, `LoadImgFromURL`, envio SMTP/Indy. |
| `Byte.Json` | Wrappers fluentes sobre `System.JSON`: `iJsonObj/TJsonObj`, `iJsonVal/TJsonVal`, `iJsonArr/TJsonArr`. Usar no lugar de `TJSONObject` cru em código novo. |
| `Byte.Utils.NativeXLSExport` | Gerador XLS BIFF5 nativo (`DataSetToXLS`, `StringGridToXLS`, `TXLSWriter`). Código de terceiros (Radek Cervinka); **não segue o padrão Byte** (procedural, `uses` sem namespace, depende de VCL). Evitar mexer. |

### 2.2 Integrações — padrão `Byte.Controller.*` / `Byte.Api.*` / `Byte.FreeMClass.*`

| Unit | Serviço | Observação |
|---|---|---|
| `Byte.Api.PlacaFipe` | Consulta de veículo por placa | Exemplo mais simples e limpo do padrão. Bom modelo para units novas. |
| `Byte.Controller.Logme_v1` | Tributos por EAN/NCM (inclui IBS/CBS/IS – reforma tributária) | Usa `record TItem` e `TList<TItem>`. URL em `http` (sem TLS). |
| `Byte.Controller.MelhorEnvio_v1` | Frete (cotação, carrinho, compra, etiqueta) | Usa `iMelhorEnvioBase<T>` genérica. Lê/grava tokens na tabela `CONFIG_MELHORENVIO` via `TEntidade`. Renova token automaticamente. |
| `Byte.Controller.Nummus` | Cashback / fidelidade | Genérica `iNummusBase<T>`. Lê tabela `CONVENIO`; grava ID Nummus no cliente. |
| `Byte.Controller.PosControle` | TEF/POS PosControle | Há 3 variantes (ver armadilhas): `PosControle`, `PosControle_v1`, `PosControle.SmartTef`. |
| `Byte.Controller.Stone.SmartTef` | TEF Stone (comunicação local por IP:porta) | Usa chave "ativação" em Base64 (não é criptografia). |
| `Byte.Controller.Tef.SuperTef` | TEF SuperTef | Usa componente `TDTSuperTEF`. |
| `Byte.FreeMClass.Produto` | Consulta de produto por código de barras (FreeMClass) | Depende de `uMulticlass`. |
| `Byte.FreeMClass.XML` | Reescreve/envia XML de NF-e (dados do emitente, autXML) | Depende de `Xml.Reader/Builder`. |
| `Byte.TokenAws` | Obtém JWT da API interna Byte (`JWTAuth`) | Contém credencial no código (ver §6). |

### 2.3 Armazenamento / mensageria — padrão `*.Service`

| Unit | Serviço |
|---|---|
| `Byte.AWS.S3` | S3 via `Data.Cloud.AmazonAPI` (Send/Get/Delete/CreateFolder, metadados, progresso FMX). |
| `Byte.AWS.Sdk.S3` | S3 via SDK `AWS.S3` (somente `SendObject`). **Mesmos nomes e GUIDs** da unit acima. |
| `PlugStorage.Service` | PlugStorage: guarda XML fiscal, usuários, contador, NF-e destinadas (usa `iTable`). |
| `Plugzapi.Service` | WhatsApp via Plugzapi (instância, QR code, msg, PDF, boleto). |
| `NebulaZap.Service` | WhatsApp via NebulaZap (mesmo conjunto de operações + parear/desconectar). |
| `Whatsapp.EvolutionApi.Service` | WhatsApp via Evolution API (inclui delay aleatório entre mensagens `GenDelayMsg`). |

As três de WhatsApp expõem API **quase idêntica** (`EnviaMsg`, `EnviaPdf`, `Boletos_EnviaPdf`, `Status`, `QrCode`). Ao adicionar um provedor, copie a forma de uma delas.

---

## 3. Convenções de código (seguir à risca)

### 3.1 Nomes
- **Unit:** `Byte.<Camada>.<Nome>` (ex.: `Byte.Controller.Nummus`) ou `<Provedor>.Service`. O nome do arquivo = nome da unit.
- **Interface:** prefixo minúsculo `i` (`iPlacaFipe`, `iJsonObj`); algumas mais novas usam `I` maiúsculo (`IFreeMClassXml`, `IControllerStoneSmartTef`). Em código novo, preferir `i` minúsculo para manter com a maioria.
- **Classe:** `T` + nome (`TPlacaFipe`). Genéricos `TXBase<T: IInterface>`.
- **Campos:** `F` + nome (`FToken`). **Parâmetros:** `A` + nome (`AValue`). **Variáveis locais:** `v` + nome (`vResp`, `vJsonObj`). Código legado de `Byte.Lib` usa `p` em parâmetros (`pValor`) – não propagar.
- **Constantes:** `C_` + MAIÚSCULAS (`C_URL`, `C_TIMEOUT`). Regex em `Byte.Consts` como `C_EXP_*`.
- **Idioma:** nomes de domínio e mensagens ao usuário em **português**; termos técnicos em inglês.

### 3.2 Formatação
- Indentação de **2 espaços**; atribuição escrita `x:= y` (sem espaço antes de `:=`, com espaço depois) na maior parte do código.
- `begin` na mesma linha do `if/else/on E:Exception do` em vários pontos (`if ... then begin`).
- Sem regiões, exceto em `Byte.Lib` (`{$REGION 'NOME'}` em maiúsculas).
- Comentários em português, com `//`.

### 3.3 Estrutura obrigatória de uma integração (padrão "interface fluente")

```pascal
unit Byte.Controller.Exemplo;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D, Byte.Json;

const
  C_URL     = 'https://api.exemplo.com.br/';
  C_TIMEOUT = 30000;

type
  iExemplo = interface
  ['{GUID-NOVO-E-UNICO}']                      // gerar GUID novo (Ctrl+Shift+G)
    function Sucesso: Boolean;
    function Mensagem: String;
    function TokenApi(AValue: String): iExemplo;   // setters devolvem Self
    function Consulta(AId: String): iExemplo;      // ações devolvem Self
  end;

  TExemplo = class(TInterfacedObject, iExemplo)
  private
    FSucesso: Boolean;
    FMsg, FToken: String;
    constructor Create;
    destructor Destroy; override;
    procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
  public
    class function New: iExemplo;
    function Sucesso: Boolean;
    function Mensagem: String;
    function TokenApi(AValue: String): iExemplo;
    function Consulta(AId: String): iExemplo;
  end;

implementation

class function TExemplo.New: iExemplo;
begin
  Result:= Self.Create;
end;

function TExemplo.Consulta(AId: String): iExemplo;
var
  vResp: IResponse;
begin
  Result:= Self;
  try
    vResp:= TRequest.New.BaseURL(C_URL)
              .Timeout(C_TIMEOUT)
              .Resource('consulta/' + AId)
              .ContentType('application/json')
              .AcceptEncoding('UTF-8')
              .AddHeader('Authorization', 'Bearer ' + FToken)
              .Get;
    if vResp.StatusCode = 200 then
      SetReqResult(True, 'OK')
    else
      raise Exception.Create(vResp.Content);
  except
    on E: Exception do
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
  end;
end;
```

Regras do padrão:
1. **Uso:** `TExemplo.New.TokenApi('x').Consulta('1')` e depois `if Obj.Sucesso then ... else ShowMessage(Obj.Mensagem)`.
2. **Erro não vaza como exceção** para o chamador: o método captura, chama `SetReqResult(False, msg)` e retorna `Self`. O chamador testa `Sucesso`/`Mensagem`. (Exceções são levantadas só em casos específicos, ex.: `TTokenAws.GetJWT`, `TLib.CheckInternet`.)
3. **Validar entradas no início** do método, `SetReqResult(False, ...)` e `Exit`.
4. **Gerenciamento de memória:** a classe é referenciada por interface (contagem de referência). Objetos `TJSONObject/TJSONValue` criados dentro do método ficam em `try..finally .Free`. Prefira `Byte.Json` para evitar `Free` manual.
5. **Construtor/destrutor ficam `private`** e só `New` cria o objeto.
6. **Provedor com autenticação reutilizável** → classe base genérica `TXBase<T: IInterface>` com `[Weak] FParent: T` e `function &End: T;`, para encadear (`Obj.Base.ClientID(1).&End.Metodo`). Exemplos: `TMelhorEnvioBase<T>`, `TNummusBase<T>`, `TNebulazapBase<T>`, `TPlugzapi<T>`, `TEvolutionApi<T>`.
7. **Acesso a banco** sempre via `TEntidade.New` → `EntidadeBase.TextoSQL('... :pParam')` + `AddParametro('pParam', valor)` + `Consulta`; escrita via `EntidadeBase.Iquery.ExecQuery`. Parâmetros nomeados com prefixo `p`. **Nunca concatenar valores do usuário no SQL.**
8. **HTTP:** sempre `RESTRequest4D` (`TRequest.New.BaseURL(...).Timeout(...)...`). Evitar `TIdHTTP` direto (existe só em `Byte.Lib` e `NebulaZap` para download de imagem/e-mail).
9. **Dados hierárquicos de resposta** → `record` ou classes simples (`TItem`, `TProduct`) e `TList<>`/`TObjectList<>`.

### 3.4 Compatibilidade VCL / FMX
- Diretivas já usadas: `{$IFDEF MSWINDOWS}` e `{$IFDEF FMX}`. Novas dependências visuais **devem** ficar dentro dessas diretivas.
- Hoje há vazamento de VCL em units de integração (ver §6.8). Não aumentar.

### 3.5 Encoding e quebra de linha — CUIDADO
- Maioria dos arquivos está em **ANSI / ISO-8859-1 (Windows-1252) com CRLF**. Alguns são ASCII puro. `Byte.Controller.Stone.SmartTef.pas` tem **CRLF e LF misturados**.
- Editar com ferramenta que regrave em UTF-8 **corrompe acentos** (`ç`, `ã`, `é` em mensagens e na regex de `Byte.Consts`). Ao editar fora da IDE, preservar o encoding original. Dentro da RAD Studio não há problema.
- Preservar CRLF. Não "normalizar" tudo num commit só (polui o diff).

---

## 4. Como mexer sem quebrar

1. **Nunca** altere a assinatura de método de `interface` publicada sem procurar os usos no projeto principal (a ByteLib é consumida por outros sistemas).
2. **GUID de interface é único.** Ao copiar uma unit para criar outra, **gere um GUID novo** (já há duplicatas – §6.2).
3. Nome de arquivo = nome da unit = entrada no `uses`. Não clonar unit sem trocar a linha `unit ...;`.
4. Constantes de URL/timeout ficam no topo da `interface` (`C_URL`, `C_TIMEOUT`). Não espalhar literais no corpo.
5. Segredos (tokens, senhas, chaves) **não** vão para o código — receber por setter (`TokenApi`, `Token`, `Usuario`/`Senha`) ou ler da base/configuração.
6. Depois de alterar uma integração, testar o fluxo feliz **e** os dois caminhos de erro (HTTP != 200 e exceção de rede/timeout), pois `Sucesso/Mensagem` é o contrato.
7. Não há testes automatizados nesta pasta. Teste manual no projeto consumidor.

### Checklist para criar uma integração nova
- [ ] Copiar `Byte.Api.PlacaFipe.pas` como base e renomear (unit + tipos + **GUID novo**).
- [ ] Definir `C_URL` e `C_TIMEOUT`.
- [ ] Interface com `Sucesso`, `Mensagem`, setters fluentes e ações.
- [ ] `SetReqResult` + `try/except` em toda ação pública.
- [ ] JSON via `Byte.Json` ou `try..finally Free`.
- [ ] Credenciais por parâmetro.
- [ ] Salvar em ISO-8859-1/CRLF se a pasta for mantida nesse padrão.
- [ ] Atualizar a tabela do §2 deste arquivo.

---

## 5. Dependências para compilar

- Delphi com VCL (e FMX para os trechos com `{$IFDEF FMX}`): `System.JSON`, `System.Net*`, `Data.Cloud.AmazonAPI`, Indy (`Id*`, OpenSSL – `Byte.Lib` força TLS 1.2).
- Pacotes de terceiros no Library Path: **RESTRequest4D**, **Dataset.Serialize**, **DTSuperTEF**, **uMulticlass (FreeMClass)**, **Xml.Reader/Xml.Builder**, **AWS SDK (AWS.S3/AWS.Client)**.
- Units internas da ByteLib fora desta pasta (ver §1).
- Atenção: **`Byte.AWS.S3` e `Byte.AWS.Sdk.S3` não podem ser usadas juntas** no mesmo `uses` sem qualificar, pois declaram os mesmos tipos.

---

## 6. Pontos de atenção encontrados na leitura inicial

Não foram corrigidos (análise inicial). Itens marcados *[verificar]* dependem de confirmar com compilação/uso real.

### Segurança (prioridade alta)
1. **Credenciais e segredos no código-fonte.** Há usuário/senha de API em `Byte.TokenAws`, token fixo `C_TOKEN` em `Byte.Controller.Tef.SuperTef`, senha de verificação em `Byte.Controller.Stone.SmartTef`, chave de "criptografia" fixa em `Byte.Lib` (`Crypto/Decrypto`) e em `Byte.Controller.MelhorEnvio_v1` (`GetDados`). Quem tem o `.pas`/executável tem as credenciais. Recomenda-se rotacioná-las e movê-las para configuração/servidor. (Valores intencionalmente não reproduzidos aqui.)
2. **`TLib.Crypt` é XOR** com chave repetida: é ofuscação, não criptografia. Em `Stone.SmartTef`, `Encrypt/Decrypt` é só Base64. Não usar para dado sensível.
3. **Token na URL** em `PlugStorage.Service` (token vai em query string) – aparece em logs de proxy/servidor.
4. **`Byte.Controller.Logme_v1` usa `http://`** (sem TLS).
5. `Byte.Controller.Stone.SmartTef` monta URL como `'http:\\' + IP + ':' + porta` (barras invertidas) *[verificar]* — o correto é `http://`.

### Estrutura
6. **Unit duplicada:** `Byte.Controller.PosControle_v1.pas` declara `unit Byte.Controller.PosControle;` (mesmo nome de `Byte.Controller.PosControle.pas`). Se ambos entrarem no projeto, o compilador acusa duplicidade; o arquivo não corresponde ao nome da unit.
7. **GUIDs de interface repetidos:** `{AC24B481-...}` em 5 units (`TokenAws`, 3× PosControle, `SuperTef`); `{1EDD7045-...}` e `{1D1B1F01-...}` em 3 units de WhatsApp; os GUIDs de `iAWSs3`/`iAWSs3Config` nas duas units AWS. Com mesma GUID, `Supports/QueryInterface/as` pode resolver a interface errada se duas coexistirem na mesma aplicação.
8. **Vazamento de VCL** em units de integração (`Byte.Controller.Nummus` usa `Vcl.StdCtrls`; `Byte.AWS.S3` chama `Application.ProcessMessages`; `NebulaZap` usa `Forms`/`Graphics`/`ShellAPI`), o que impede reutilizar em serviço/console/FMX.
9. Três variantes de PosControle e `*_v1` sem documentação de qual é a vigente.

### Bugs prováveis
10. `TLib.GetRandomNumber(Start, End)` faz `Start + Random(End)`: o resultado pode passar de `End`. O correto seria `Start + Random(End - Start + 1)`.
11. `TLib.CheckInternet` captura a exceção e relança `'Sem conexão...'` — o retorno `False` nunca é visto pelo chamador; além disso o `finally` libera o cliente mesmo se a criação falhar.
12. `TJsonObj.SetJsonObj` substitui `FJsonObj` sem liberar o anterior (vazamento) e o destrutor libera o objeto recebido (risco de *double free* se o chamador também o liberar).
13. `Byte.Controller.Nummus.RegistraConsumidor_Anotacao` tem `except` vazio: qualquer falha é engolida e a função retorna `''`.
14. `TLib.GetTokenApiProdutos` devolve `''` silenciosamente quando o status não é 200 (sem mensagem de erro) e não trata `ParseJSONValue = nil`.
15. `TPlacaFipe.PreencheDadosVeiculo` assume que o JSON é objeto; se vier inválido, `vJsonObj` é `nil` e há violação de acesso.
16. `Extenso` usa aritmética de ponto flutuante nos centavos (`Frac*100`) → pode errar 1 centavo; `Max` declarado maior que o limite real de `LongInt` (2.147.483.647).
17. Chamadas HTTP síncronas na thread principal em quase todas as integrações (timeouts de 30–120 s travam a UI). Existe `TLib.CustomThread` para isso, mas não é usada de forma consistente.

### Melhorias sugeridas (para fases seguintes)
- Extrair um `iHttpClient`/`TBaseService` comum (hoje a montagem de `TRequest` + tratamento de erro é repetida em ~15 units).
- Criar uma interface única de mensageria WhatsApp com 3 adaptadores (Plugzapi, NebulaZap, Evolution).
- Unificar `Byte.AWS.S3` e `Byte.AWS.Sdk.S3` atrás de uma só interface.
- Centralizar segredos/URLs em configuração.
- Padronizar encoding (UTF-8 com BOM é aceito pela IDE) e finais de linha, em commit separado.
- Adicionar testes (DUnitX) ao menos para `Byte.Lib` (validadores, `RoundABNT`, `Extenso`) e `Byte.Json`.

---

## 7. Mapa rápido (onde mexer para cada necessidade)

| Preciso... | Vá em |
|---|---|
| Validar CPF/CNPJ/EAN/e-mail/CEP | `Byte.Lib` → `TLib.IsCPF`, `IsCNPJ`, `ValidaEAN13`, `Valida(.., tvXxx)`; regex em `Byte.Consts` |
| Formatar doc, zeros, remover acento, valor por extenso | `Byte.Lib` (região FORMATAÇÃO / ÚTEIS) |
| Montar/ler JSON | `Byte.Json` |
| Enviar arquivo ao S3 | `Byte.AWS.S3` (ou `Byte.AWS.Sdk.S3` com progresso) |
| Enviar WhatsApp | `Plugzapi.Service`, `NebulaZap.Service` ou `Whatsapp.EvolutionApi.Service` |
| Cobrança em maquininha | `Byte.Controller.Stone.SmartTef`, `...PosControle*`, `...Tef.SuperTef` |
| Calcular frete / etiqueta | `Byte.Controller.MelhorEnvio_v1` |
| Cashback | `Byte.Controller.Nummus` |
| Tributos por produto | `Byte.Controller.Logme_v1` |
| Dados de veículo por placa | `Byte.Api.PlacaFipe` |
| Dados de produto por EAN | `Byte.FreeMClass.Produto` |
| Reescrever XML de NF-e | `Byte.FreeMClass.XML`, `PlugStorage.Service` |
| Exportar DataSet para Excel | `Byte.Utils.NativeXLSExport` → `DataSetToXLS` |

---
*Manter este arquivo atualizado sempre que uma unit for criada, renomeada ou removida.*
