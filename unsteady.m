function[t,T]=unsteady(tspan,T0,M,S,f)
options=odeset('Mass',M);
[t,T]=ode23t(@dstate, tspan, T0, options);
    function dTdt = dstate(t,T)
        dTdt = -S*T+f;
    end
end