# Pricing Module

On va rechallenger complètement le module pricing de jo_libs qui ne me plaît plus.

On va utiliser beaucoup les classes et les metatables de Lua.

La plus petite unité est l'`Cost`, un composant d'un `PriceClass`.

On a aussi une `PriceGroupClass`, composée de plusieurs `PriceClass`.

Ce que je vais décrire ci-dessous est la structure interne canonique en Lua.

À différencier de la manière dont les données sont passées au constructeur puis normalisées.

Le constructeur pourra accepter plusieurs syntaxes simplifiées, mais il devra toujours produire la structure interne canonique.

---

# COST

```lua
MoneyCost = {
    money = X
}

GoldCost = {
    gold = X
}

RolCost = {
    rol = X
}

ItemCost = {
    item = "XXX",
    quantity = X,
    keep = bool
}
```

## Valeurs par défaut

Pour `ItemCost` :

```lua
quantity = 1
keep = false
```

Donc :

```lua
{ item = "water" }
```

devient :

```lua
{ item = "water", quantity = 1, keep = false }
```

Un `Cost` représente toujours un seul type de coût.

Exemples valides :

```lua
{ money = 12 }

{ gold = 3 }

{ rol = 1 }

{ item = "water", quantity = 2, keep = false }
```

---

# PRICECLASS

Un `PriceClass` représente une liste canonique de `Cost`.

Tous les `Cost` d'un même `PriceClass` sont liés par un **AND implicite**.

Structure canonique :

```lua
{
    isProcessing = false,

    costs = {
        { money = 12 },
        { item = "water", quantity = 2, keep = false }
    }
}
```

signifie :

```
12 money ET 2 water
```

## Contraintes

`costs` ne peut contenir qu'un :

- MoneyCost
- GoldCost
- RolCost

Les doublons sont automatiquement fusionnés.

Il peut contenir plusieurs `ItemCost` pour le même `item` si la propriété `keep` est différente.

Exemple valide :

```lua
{
    isProcessing = false,

    costs = {
        { money = 1 },
        { gold = 2 },
        { item = "acid", quantity = 1, keep = false },
        { item = "water", quantity = 4, keep = false }
    }
}
```

Exemple non canonique :

```lua
{
    { money = 12 },
    { item = "water", quantity = 2 },
    { money = 4 }
}
```

devient automatiquement :

```lua
{
    isProcessing = false,

    costs = {
        { money = 16 },
        { item = "water", quantity = 2, keep = false }
    }
}
```

Même logique pour `gold` et `rol`.

## Fusion des ItemCost

Deux `ItemCost` sont fusionnés si :

- `item` est identique
- `keep` est identique

Exemple :

```lua
{
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 3, keep = false }
}
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { item = "water", quantity = 5, keep = false }
    }
}
```

Ceci est aussi autorisé :

```lua
{
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 1, keep = true }
}
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { item = "water", quantity = 2, keep = false },
        { item = "water", quantity = 1, keep = true }
    }
}
```

Cela signifie :

```
3 water sont nécessaires, mais seulement 2 water seront retirés.
```

Le `ItemCost` avec `keep = true` compte dans le prérequis, mais n'est pas consommé.

## État interne

Chaque `PriceClass` possède un état de traitement directement dans sa forme canonique :

```lua
isProcessing = false
```


Le constructeur initialise toujours cet état :

```lua
function PriceClass.new(data)
    local self = normalizePrice(data)

    self.isProcessing = false
    self.costs = self.costs or {}

    return setmetatable(self, PriceClassMeta)
end
```

Lorsqu'une méthode modifie un `PriceClass`, elle attend que `isProcessing` soit à `false` avant de continuer.

À terme, les mutations devront uniquement passer par les méthodes de la classe.

## Mathematic operators

On utilise `__add` pour fusionner deux `PriceClass` sans modifier les opérandes.

En Lua, `__add` correspond à l'addition :

```lua
myTable + object
object + myTable
```

Si la metatable de `myTable` possède une clé `__add` qui pointe vers une fonction, cette fonction est appelée avec les deux opérandes dans l'ordre.

On pourra donc faire :

```lua
local newPrice = PriceClass.new({
    money = 12
}) + PriceClass.new({
    item = "water",
    quantity = 2
})
```

`__add` retourne toujours un nouveau `PriceClass`.

Les deux opérandes d'origine restent inchangés.

Résultat :

```lua
{
    isProcessing = false,

    costs = {
        { money = 12 },
        { item = "water", quantity = 2, keep = false }
    }
}
```

Exemple conceptuel :

```lua
PriceClassMeta.__add = function(left, right)
    local leftPrice = normalizePrice(left)
    local rightPrice = normalizePrice(right)

    return PriceClass.new(mergeCosts(leftPrice.costs, rightPrice.costs))
end
```

## PriceClass:add()

`add()` accepte un `PriceClass` canonique ou un prix simplifié.

On garde `add()` en plus de `__add` parce que les deux opérations n'ont pas le même effet :

```lua
local newPrice = price1 + price2
```

crée un nouveau `PriceClass` sans modifier `price1` ni `price2`.

```lua
price1:add(price2)
```

ajoute `price2` dans `price1` et modifie `price1`.

Exemple :

```lua
price:add({
    money = 10,
    item = "water"
})
```

Si le prix passé est simplifié, il est normalisé en `PriceClass`.

Ensuite, `add()` fusionne les coûts normalisés dans `self.costs`.

```lua
self.costs = mergeCosts(self.costs, normalizedPrice.costs)
return self
```

## PriceClass:get()

Sans argument, `get()` retourne la liste des coûts :

```lua
price:get()
```

retourne :

```lua
price.costs
```

Pour récupérer un coût précis, on utilise des getters dédiés :

```lua
price:getMoney()
price:getGold()
price:getRol()
```

Ces appels retournent le `Cost` correspondant dans `price.costs`, ou `nil` s'il n'existe pas.

Pour les items :

```lua
price:getItems()
```

retourne la liste des `ItemCost` présents dans `price.costs`.

## Exemples de création

```lua
PriceClass.new({
    money = 2,
    gold = 4
})
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { money = 2 },
        { gold = 4 }
    }
}
```

---

```lua
PriceClass.new({
    money = 2,
    gold = 4,
    item = "water"
})
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { money = 2 },
        { gold = 4 },
        { item = "water", quantity = 1, keep = false }
    }
}
```

---

```lua
PriceClass.new({
    money = 2,
    gold = 4,
    item = "water",
    {
        item = "acid",
        quantity = 3
    }
})
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { money = 2 },
        { gold = 4 },
        { item = "water", quantity = 1, keep = false },
        { item = "acid", quantity = 3, keep = false }
    }
}
```

---

```lua
PriceClass.new({
    { money = 12 },
    { item = "water", quantity = 2 },
    { money = 4 }
})
```

devient :

```lua
{
    isProcessing = false,

    costs = {
        { money = 16 },
        { item = "water", quantity = 2, keep = false }
    }
}
```

---

# PRICEGROUPCLASS

Un `PriceGroupClass` représente une liste de `PriceClass`.

Structure canonique :

```lua
{
    operator = "and", -- "and" ou "or"

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 12 },
                { item = "water", quantity = 2, keep = false }
            }
        },

        {
            isProcessing = false,

            costs = {
                { gold = 4 },
                { item = "acid", quantity = 1, keep = false }
            }
        }
    }
}
```

## Contraintes

`prices` contient toujours une liste de `PriceClass`.

Jamais directement des `Cost`.

Correct :

```lua
{
    operator = "or",

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 2 }
            }
        },

        {
            isProcessing = false,

            costs = {
                { gold = 5 }
            }
        }
    }
}
```

Incorrect :

```lua
{
    operator = "or",

    prices = {
        { money = 2 },
        { gold = 5 }
    }
}
```

---

## Constructeur

Si `operator` n'est pas précisé :

```lua
operator = "or"
```

### Exemple

```lua
PriceGroupClass.new({
    money = 2,
    gold = 5
})
```

devient :

```lua
{
    operator = "or",

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 2 }
            }
        },

        {
            isProcessing = false,

            costs = {
                { gold = 5 }
            }
        }
    }
}
```

Signifie :

```
2 money OU 5 gold
```

---

Avec :

```lua
operator = "and"
```

```lua
PriceGroupClass.new({
    operator = "and",
    money = 2,
    gold = 5
})
```

devient :

```lua
{
    operator = "and",

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 2 }
            }
        },

        {
            isProcessing = false,

            costs = {
                { gold = 5 }
            }
        }
    }
}
```

Signifie :

```
2 money ET 5 gold
```

---

On peut aussi créer un `PriceGroupClass` avec une liste de `PriceClass` déjà construits :

```lua
local price1 = PriceClass.new({
    money = 2
})

local price2 = PriceClass.new({
    gold = 5
})

PriceGroupClass.new({ price1, price2 })
```

devient :

```lua
{
    operator = "or",

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 2 }
            }
        },

        {
            isProcessing = false,

            costs = {
                { gold = 5 }
            }
        }
    }
}
```

Signifie :

```
2 money OU 5 gold
```

---

# PriceGroupClass:compact()

`compact()` retourne un **nouveau `PriceClass`**.

Il ne modifie jamais le `PriceGroupClass` d'origine.

Il est uniquement autorisé si :

```lua
operator == "and"
```

Exemple :

```lua
{
    operator = "and",

    prices = {
        {
            isProcessing = false,

            costs = {
                { money = 2 },
                { item = "water", quantity = 1, keep = false }
            }
        },

        {
            isProcessing = false,

            costs = {
                { money = 5 },
                { gold = 1 },
                { item = "water", quantity = 3, keep = false }
            }
        }
    }
}
```

```lua
priceGroup:compact()
```

retourne :

```lua
{
    isProcessing = false,

    costs = {
        { money = 7 },
        { gold = 1 },
        { item = "water", quantity = 4, keep = false }
    }
}
```

Le `PriceGroupClass` reste inchangé.

---

Si :

```lua
operator == "or"
```

Alors :

```lua
priceGroup:compact()
```

doit lever une erreur.

---

# Résumé des règles

## Cost

- représente une seule unité atomique de coût
- type : money, gold, rol ou item
- `quantity = 1` par défaut
- `keep = false` par défaut

## PriceClass

- objet canonique composé de `isProcessing` et `costs`
- `costs` contient une liste canonique de `Cost`
- AND implicite entre tous les composants de `costs`
- un seul MoneyCost
- un seul GoldCost
- un seul RolCost
- plusieurs ItemCost pour le même `item` autorisés si `keep` différent
- même `item` + même `keep` ⇒ fusion
- même `item` + `keep` différent ⇒ prérequis commun, consommation séparée
- `isProcessing = false` est initialisé dans l'objet canonique
- pas de storage privé externe pour `isProcessing`
- supporte `PriceClass + PriceClass` via `__add`
- `__add` retourne un nouveau `PriceClass` sans modifier les opérandes
- `add()` accepte un `PriceClass` canonique ou un prix simplifié
- `add()` modifie l'opérande de gauche et retourne `self`
- `get()` retourne `costs`
- `getMoney()`, `getGold()` et `getRol()` retournent le `Cost` correspondant
- `getItems()` retourne la liste des `ItemCost`

## PriceGroupClass

- représente une liste de `PriceClass`
- `operator` vaut `"or"` par défaut
- `operator` peut être `"and"` ou `"or"`
- `prices` contient toujours des `PriceClass`
- `prices` ne contient jamais directement des `Cost`
- un argument plat est éclaté selon `operator`
- le constructeur accepte une liste de `PriceClass` déjà construits
- `compact()` est autorisé uniquement avec `operator = "and"`
- `compact()` retourne un nouveau `PriceClass`
- `compact()` ne modifie jamais le `PriceGroupClass`

---

La logique de choix d'un prix lorsqu'un `PriceGroupClass` possède un `operator = "or"` est **hors scope** de ce module.

Le module pricing décrit, normalise et manipule les prix.

Le choix de l'option à utiliser est laissé au système appelant.
