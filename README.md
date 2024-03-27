# FV_Project
Design and Formal Verification of a Sequence Detector FSM for Enhanced Security Applications

Project Description:
In this project, a sequence detector Finite State Machine(FSM) is verified and developed that identifies a specific sequence of binary inputs. This FSM will be used as part of a security system to detect authorized sequences for operation activation. 


VC Formal AEP App: App for Automatically Extracted Properties.
The AEP app will extract properties from your design written in a supported HDL, such as SV, and analyze them automatically to provide results. This is done automatically, and writing properties or assertions is not necessary.

VC Formal FXP: Formal X-Propagation App.
The FXP app will scan your design written in a supported HDL, such as SV, for "don't cares/x's" to observe if they can propagate through the system. The app injects don't cares in designated parts of your design and monitors their propagation. This is done automatically, and writing properties or assertions is not necessary.

VC Formal FCA: Formal Coverage Analyzer.
The FCA App can be utilized to qualify formal property verification with coverage by identifying unreachable goals, either because of constraints or due to uncovered goals in simulation. Formal core coverage reachability analysis can identify the minimum amount of design code required for formal engines to reach the full or specified proof depths. Writing properties or assertions is not necessary.

VC Formal FPV: Formal Property Verification.
The FPV app can verify various design properties, such as assertions to validate design behavior, assumptions to restrict the formal verification environment, and coverage properties to track significant or expected events. Writing properties in SVA (SystemVerilog Assertions) is required for this app.
