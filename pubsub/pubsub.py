import os
class Publisher:

    def __init__(self, name, broker):
        print "Instantiating publisher ", name
        self.name = name
        self.broker = broker

    def addTopic(self, topic):
        # topic is a simple label allowed to be a unix directory name
        self.broker.registerTopicWriter(self, topic)

    def publish(self, topic, message):
        # assuming a simple string for message
        self.broker.publish(self.name, topic, message)
        print self.name, ": published the following message on ", topic

class Subscriber:

    def __init__(self, name, broker):
        print "Instantiating subscriber", name
        self.name = name
        self.broker = broker

    def addTopic(self, topic):
        # topic is a simple label allowed to be a unix directory name
        self.broker.registerTopicReader(self, topic)

    def receive(self, topic, message):
        # assuming a simple string for message
        print self.name, ": received the following message on ", topic
        print message

class Broker:

    def __init__(self, store):
        # store is a path to directory, can be made a writer
        self.root = store + '/'
        self.pubs = {}
        self.subs = {}
        self.topics = set()
        self.last = 0
        # create directory if it doesn't exist

    def createTopicStore(self, topic):
        self.topics.add(topic)
        self.pubs[topic] = set()
        self.subs[topic] = set()
        if not os.path.exists(self.root + topic):
            os.makedirs(self.root + topic)

    def write(self, topic, message):
        with open(self.root + topic + '/' + str(self.last), 'w') as f:
            f.write(message)

    def delete(self, topic, mid):
        f = self.root + topic + '/' + str(self.last)
        if os.path.isfile(f):
            os.remove(f)

    def registerTopicWriter(self, pub, topic):
        if topic not in self.topics:
            self.createTopicStore(topic)
        self.pubs[topic].add(pub)

    def registerTopicReader(self, sub, topic):
        if topic not in self.topics:
            self.createTopicStore(topic)
        self.subs[topic].add(sub) 

    def publish(self, pub, topic, message):
        self.last += 1
        # persist
        self.write(topic, message)
        if topic not in self.topics:
            self.registerTopicWriter(pub, topic)
            # the message goes to no client
        for sub in self.subs[topic]:
            sub.receive(topic, message)
        self.delete(topic, self.last)
