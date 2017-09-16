 # Teste técnico - Agendor

Esse teste consiste em atualizar um projeto já existente, corrigindo seus bugs e implementando novas funcionalidades. O aplicativo em questão é um gerador de nomes de startups, onde o usuário insere uma ou mais palavras-chave, e após clicar no botão "Gerar" são exibidas dez sugestões de nomes.

Abaixo estão listados 7 itens que devem ser realizados nesse teste. Além disso, também será analisado a qualidade do código implementado, como nomes de variáveis/métodos/classes, separação de responsabilidades, testes automatizados, etc.

## 1 - Favoritos (veja imagem de referência)

### História
**Como** usuário
**Quero** ter um botão para marcar um nome como meu favorito
**Para** que eu consiga registrar os melhores nomes para a minha startup

### Cenário
**Dado** que foram gerados nomes corretamente
**E** que estou visualizando os nomes gerados
**Quando** eu pressionar no botão de favorito de um nome
**Então** esse botão deve ficar selecionado, indicando que esse nome é um favorito
**E** deve exibir uma mensagem informando que esse nome foi adicionado com sucesso aos favoritos
**E** essa informação deve ser persistida no banco de dados

---

## 2 - Melhoria no layout (veja imagem de referência)

### História
**Como** usuário
**Quero** botões maiores
**Para** facilitar o uso correto do aplicativo

### Cenário 1
**Dado** que estou na tela inicial
**Quando** eu pressionar Gerar
**Então** deve exibir a lista com os nomes gerado

### Cenário 2
**Dado** que estou na tela inicial
**Quando** eu pressionar Limpar
**Então** deve excluir os nomes da listagem

---

## 3 - Comportamento do botão Limpar

### História
**Como** usuário
**Quero** manter os favoritos ao limpar os resultados
**Para** não perder os nomes preferidos

### Cenário
**Dado** que estou na tela inicial
**Quando** eu pressionar Limpar
**Então** deve excluir os nomes da listagem, exceto os itens favoritados

---

## 4 - Ordenação

### História
**Como** usuário
**Quero** ver os itens favoritos e os mais recentes no topo da listagem
**Para** facilitar a localização desses itens

### Cenário
**Dado** que estou na tela inicial
**Quando** eu pressionar Gerar
**Então** deve exibir a lista ordenada com os nomes favoritos
**E** posteriormente com os nomes por ordem de criação da mais recente para a menos recente

---

## 5 - Ênfase nos novos nomes gerados

### História
**Como** usuário
**Quero** ter uma indicação visual (texto em negrito) dos novos nomes gerados
**Para** identificar quais itens foram gerados após o último clique

### Cenário
**Dado** que estou na tela inicial
**Quando** eu pressionar Gerar
**Então** deve exibir a lista com os novos nomes em negrito
**E** os nomes antigos em fonte regular 

---

## 6 - Não exibir itens repetidos 

### História
**Como** usuário
**Quero** que os nomes gerados não se repitam
**Para** não perder tempo vendo um mesmo nome que já vi
**E** poder ter mais opções de nomes

### Cenário
**Dado** que o usuário está na tela inicial
**Quando** pressionar Gerar
**Então** deve exibir a lista com nomes únicos

**Dado** que o nome “Agenda Vendedor” foi gerado
**Quando** pressionar Gerar novamente
**Então** o nome “Agenda Vendedor” não pode aparecer de novo

**Dado** que o nome “Agenda Vendedor” foi gerado
**E** pressionei o botão Limpar
**Quando** pressionar Gerar
**Então** o nome “Agenda Vendedor” pode aparecer de novo

---

## 7 - Consistência na geração de nomes

### História
**Como** usuário
**Quero** que sempre sejam gerados pelo menos 10 nomes
**Para** ter uma quantidade suficiente de opções sem ter que clicar em Gerar muitas vezes

**Como** usuário
**Quero** que sempre sejam gerados nomes com no mínimo 3 caracteres
**Para** atender o meu padrão de qualidade

### Cenário 1
**Dado** que o usuário está na tela inicial
**Quando** pressionar Gerar
**Então** deve exibir a lista com 10 novos nomes
**E** cada nome deve conter pelo menos 3 caracteres

### Cenário 2
**Dado** que o usuário está na tela inicial
**Quando** pressionar Gerar
**Então** deve exibir uma mensagem informativa, quando não há mais combinações possíveis

---

As alterações de layout devem ser realizadas preferencialmente no storyboard, utilizando Auto Layout, e não deve possuir erros. O aplicativo deve suportar os formatos retrato e paisagem em qualquer tamanho de iPhone, não sendo necessário tratar para iPad. 

Após a conclusão do projeto, envie-nos o projeto em um arquivo .zip, ou link de seu repositório. O uso do Git e commits bem descritos contam positivamente na avaliação :)

Boa sorte,

Equipe Agendor