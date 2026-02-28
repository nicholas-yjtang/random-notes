Someone posed this question in a discussion

They were convinced that they were an Administrator but could not run an application that requires Administrative rights (specifically mimikatz.exe)

There are multitudes of possible ways to lock down a specific user who has Administrative rights, but since this is asked in context of pentesting environments (HTB, Proving Grounds Practice, etc), I personally think it would be much easier to view the question this way

What security misconfiguration would lead to this strange scenario of having a user that seems to have quasi administrative rights?

For those who don't care for my meandering thoughts, you can just head to the [summary](#summary)  for the conclusion
## mimikatz

Let's first take a look at mimikatz.exe. 

In order to perform credential extraction, you would normally need to first run privilege debug in order to have the correction permissions

```
privilege::debug
```

Let's modify our windows setup to give this debug permission to our target user

Run **Local Security Policy** . Let's give our user the **Debug programs** rights. Notice this right is already given to the local group *Administrators*

![](Pasted%20image%2020260227083730.png)

Let's log in with our user and see if we can run mimikatz.exe

```
mimikatz.exe privilege::debug sekurlsa::logonpasswords exit
```

![](Pasted%20image%2020260227083915.png)

Looks like a failure. Let's check if the privilege is correct

```
whoami /priv
```

![](Pasted%20image%2020260228023519.png)

Looks like we are missing the **SeDebugPrivilege**

One of the requirements for running mimikatz is to make sure you are running it in an Administrative console

Let's try running the Administrative console instead. Interestingly it popped up the UAC. 

Let's key in password of this particular user

![](Pasted%20image%2020260227054011.png)

Running the same command, we find that we are able to run the privilege command

![](Pasted%20image%2020260227083456.png)

Let's check on the permissions again. We see the **SeDebugPrivilege** permission now

![](Pasted%20image%2020260228024135.png)

Let's see what this Administrator console can do besides running mimikatz

![](Pasted%20image%2020260227084243.png)

So looks like we have the **Administrator Command Prompt**, but we aren't actually *Administrators*

Let's confirm that we are indeed not a local *Administrator*

![](Pasted%20image%2020260227084527.png)

## Runas

Let's do a little side quest

Since we are here, we might as well investigate if we can try to run mimikatz with the elevated permissions without having  to run the administrative console, bypassing UAC

The runas from windows doesn't seem to have this function, but fortunately the smarter people out there has kindly provided such tools

Let's use  [RunasCS.exe](https://github.com/antonioCoco/RunasCs)

In the documentation, they provide a ==-b== or ==--bypass-uac== to bypass UAC, convenient for our usage

```
RunasCs.exe [username] [password] "mimikatz.exe privilege::debug sekurlsa::logonpasswords exit" -domain solution.local -b
```

Performing a little test first to make sure we have the **SeDebugPrivilege**

![](Pasted%20image%2020260228040956.png)

Confirming we indeed ran mimikatz inside this RunasCs with the elevated permissions. 

Once the command terminates our permission returns to normal

![](Pasted%20image%2020260228040809.png)

## The answer is always UAC

We've come this far, we should now more or less narrow down the problem to UAC, or specifically the need to elevate permissions via UAC to utilize certain privileges

If you have ever checked what happens with a local *Administrator*, you would have noticed that when you run a normal console, most of your permissions are missing. 

![](Pasted%20image%2020260228061707.png)

But if you ran it from the **run as Administrator** console, you would find you now have full permission.

This was the design and intent of the UAC

![](Pasted%20image%2020260228061829.png)

Since the scenario was not being able to run mimikatz.exe, we need to ask ourselves which other security misconfiguration would allow us to elevate our permission via UAC

Let's try the ever popular permission **SeImpersonatePrivilege**

Let's go back to the local security policy and remove **SeDebugPrivilege** from our user and add **SeImpersonlatePrivilege**

![](Pasted%20image%2020260301011039.png)

Let's take a look again to confirm we are not given the **SeImpersonatePrivilege** in our normal command prompt

![](Pasted%20image%2020260301022800.png)

Elevate our permissions via UAC and run as Administrator

![](Pasted%20image%2020260301022916.png)

And of course attempt to run mimikatz but since we don't have the correct permissions, it would fail

![](Pasted%20image%2020260301025919.png)


## Summary

Don't be misled by the term **Administrator Command Prompt**. It's just to denote the console you are running has elevated permissions

You **should** elevate your console to the highest level possible, and the only way to do that with the interactive logon is to **Run as Administrator** and UAC


