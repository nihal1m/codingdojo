#!/usr/bin/env python
# coding: utf-8

# In[1]:


from hashlib import sha256
from time import time
import json
# import hashlib, time, and json library


# In[2]:



class Block:
    """When a block is added to the chain... it contains the index, prev, transaction, and timestamp.
    Structure of blocks 
    """
    def __init__(self, index, prev, transaction, timestamp=time()):
        self.index = index 
        self.prev = prev
        self.transaction= transaction
        self.timestamp = timestamp
    
    
    def hashBlcok(self):
        """hash the block using the __dict__ in sorting the keys"""
        block = json.dumps(self.__dict__, sort_keys=True)
        return(sha256(block.encode()).hexdigest())


# In[3]:


firstblock = Block(0, 0,{"sender":"x"})
# use the Block class to input the data, so self.index = 0 self.prev = 0,  index, self.transaction = {"sender":"x"}
# remember the Block class also has timestamp=time() which is generating the time each time we run the Block class


# In[4]:


firstblock.hashBlcok()
# run the hashBlock function which takes all the inputs on Block by using self.__dict__


# In[15]:


firstblock.h1 = firstblock.hashBlcok()
# similar to the above but you add h1 to be included in the Block class structure
# so we have self.index and as well as self.h1 


# In[16]:


firstblock.h1


# In[17]:


firstblock.index


# In[18]:


secondblock = Block(1, firstblock.h1, "x")


# In[20]:


secondblock.h1 = secondblock.hashBlcok()


# In[21]:


firstblock.__dict__.copy()
#  as you see the output is a dictionary contains the Block class with h1


# In[22]:


secondblock.__dict__.copy()


# In[23]:


class Blockchain:
    def __init__(self):
        self.chain = []
        self.unconfirmedTX = []
        self.cindex= 0
    
    def createGenBlcok(self):
        genBlock = {
            'index': 0,
            'prev' : '0',
            'transaction' : []
        }
        
        genBlock = Block(genBlock['index'], genBlock['prev'], genBlock['transaction'])
        genBlock.hash = genBlock.hashBlcok()
        self.chain.append(genBlock)
    
    
    def sendTx(self, sender, receiver, amount):
        tx = {
            'sender': sender,
            'receiver': receiver,
            'amount': amount
        }
        self.unconfirmedTX.append(tx)
    
    def addBlcok(self, blcok):
        prevHash = self.getHashVlaue.hash
#         if prevHash != blcok.prev:
#             return False
        blcok.hash = blcok.hashBlcok()
        self.chain.append(blcok)
        return True
    
    @property
    def getHashVlaue(self):
        if len(self.chain) < 1:
            return None
        return(self.chain[-1])
        
    def mining(self):
        lastBlock = self.getHashVlaue
        
        blcok = {
            'index': lastBlock.index + 1,
            'prev': lastBlock.hash,
            'transaction': block.unconfirmedTX
        }
        newBlcok = Block(blcok['index'], blcok['prev'], blcok['transaction'])
        self.addBlcok(newBlcok)
        


# In[24]:


block = Blockchain()


# In[25]:


block.sendTx("Abdu", "Adam", 10)


# In[26]:


block.unconfirmedTX


# In[27]:


block.unconfirmedTX[-1]


# In[28]:


block.createGenBlcok()


# In[29]:


block.mining()


# In[30]:


for i in block.chain:
    print(i.index, i.prev, i.transaction, i.hash)


# In[31]:


import hashlib


# In[32]:


def hashString(string):
    return hashlib.sha256(string).hexdigest()


# In[33]:


def target(tx):
    guess = (str([t for t in tx ]) + str(nonce)).encode()
    targetHash = hashString(guess)
    print(targetHash)
    return targetHash[0:2] == '00'


# In[34]:


tx = {('sender', '1M7Jie65R12Z1f8zu5EvSzUnneVnNhmuqN'), ('receiver','17s1fkRehntHvfg2q7MzUZJvsLLyQTJYpp'), ('amount', 4)}


# In[35]:


str([t for t in tx])


# In[36]:


nonce = 0
while not target(tx):
    nonce += 1
print("The nonce is: ", nonce)


# In[ ]:




