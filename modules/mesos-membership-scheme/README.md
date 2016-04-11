## Mesos Membership Scheme

Mesos membership scheme provides features for automatically discovering WSO2 carbon server clusters on Apache Mesos platform.

### How it works
Once a Carbon server starts it will query container IP addresses in the given cluster via Mesos Marathon API for a given task.
Thereafter Hazelcast network configuration will be updated with the above IP addresses. As a result the Hazelcast instance will
get connected all the other members in the cluster. In addition once a new member is added to the cluster, all the other members will get connected to the new member.

### Installation

1. Apply Carbon kernel patch0012. This includes a modification in the Carbon Core component for
allowing to add custom membership schemes.

2. Copy following JAR files to the repository/components/lib directory of the Carbon server:

   ```
      jackson-core-2.5.4.jar
      jackson-databind-2.5.4.jar
      jackson-annotations-2.5.4.jar
      mesos-membership-scheme-<version>.jar
   ```

3. Update axis2.xml with the following configuration:

   ```
   <clustering class="org.wso2.carbon.core.clustering.hazelcast.HazelcastClusteringAgent" enable="true">
      <parameter name="membershipSchemeClassName">org.wso2.carbon.membership.scheme.mesos.MesosMembershipScheme</parameter>
      <parameter name="membershipScheme">mesos</parameter>
      <!-- Apache Mesos Marathon API endpoint -->
      <parameter name="MARATHON_ENDPOINT">http://mesos:8080</parameter>
      <!-- Marathon task the carbon server belongs to, use comma separated values for specifying
           multiple values. If multiple tasks are defined, carbon server will connect to all the members
           deployed under given Marathon tasks via Hazelcast. If no value is provided then it will default to
            -->
      <parameter name="MARATHON_TASK">wso2esb</parameter>
      <!-- Kubernetes namespace used -->
      <parameter name="KUBERNETES_NAMESPACE">default</parameter>
   </clustering>
```

