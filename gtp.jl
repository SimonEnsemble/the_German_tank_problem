### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ f51509b6-6c25-11ed-371e-35df2270ac8a
using CairoMakie, DataFrames, FileIO, StatsBase, Random, PlutoUI, Combinatorics

# ╔═╡ aed174c4-d5fb-459c-b9b7-1e0ebc17be0d
TableOfContents()

# ╔═╡ 21575264-8b5a-4c6b-b6ff-c2f29f76c26b
md"set up plotting theme"

# ╔═╡ 8d134dd1-7a6f-4f58-b555-7fcfe4210177
import AlgebraOfGraphics as aog

# ╔═╡ 9e831714-3ce5-4b68-83f3-e98384732554
begin
	aog.set_aog_theme!(fonts=[aog.firasans("Light"), aog.firasans("Light")])
	update_theme!(fontsize=20, linewidth=3, resolution=(500, 400))
end

# ╔═╡ 90816107-f479-4727-b8e9-405825c7c68f
colors = Dict(zip(["prior", "likelihood", "posterior", "data", "other", "other2"], aog.wongcolors()[[1, 2, 3, 4, 7, 5]]))

# ╔═╡ 08404a85-ca12-4a6c-a3b5-733e1e1d61e0
markers = Dict("prior" => :circ, "likelihood" => :star6, "posterior" => :rect)

# ╔═╡ df4fb49d-f060-4063-a1d7-de6568d3eb53
the_xlabel = "size of tank population, n"

# ╔═╡ b09ad25f-436a-49fc-9304-5e59573c7ccd
md"## simulate tank capture"

# ╔═╡ fc649f6d-223d-408a-ad4e-c8b93cfaa661
# capture k tanks from population of n
function sample_tanks(k::Int, n::Int)
	return sample(1:n, k, replace=false)
end

# ╔═╡ 8255eb75-fa6b-4e8f-9d1e-c40192009e4e
md"no. of tanks"

# ╔═╡ 4482a867-ae1f-4a82-bfd7-a826e61ccfbb
n = 20

# ╔═╡ 57115caa-0c68-461e-968f-7ac206739f7a
md"no. of captured tanks"

# ╔═╡ fb9a152f-ac8d-46f7-b061-3436a72fb4bd
k = 3

# ╔═╡ a8ad008a-14da-4032-af42-4a65e6cf598b
md"go ahead, tank capture!"

# ╔═╡ cb3c96da-4678-44bf-b149-1e13b22804e8
begin
	my_seed = 97330
	Random.seed!(my_seed)
	s = sample_tanks(k, n)
end

# ╔═╡ d563bdd8-4a22-417a-93ab-79cbbc0b7d8f
md"max observed serial no."

# ╔═╡ 3d29f507-918e-4ca4-8265-51cb1efbfc24
m = maximum(s)

# ╔═╡ 1c4f3910-29dd-447d-9c18-0f2b1bc190eb
function viz_tank_capture(s::Vector{Int}; savename=nothing, 
                          incl_data=true, n_rows::Int=1, incl_realization::Bool=true)
	img = load("tank.png")

	n_cols = ceil(Int, length(s) / n_rows)
	
	fig = Figure(resolution=(500, 400 + (n_rows-1) * 400*0.6))# resolution=(500 + (n_rows - 1) * 100, 400))

	i_s = 0
	for i = 1:n_rows
		for j = 1:n_cols
			i_s += 1
			if i_s > length(s)
				continue
			end
			sᵢ = s[i_s]

			
			the_label = incl_realization ? rich("s", subscript("$i_s"), "=$sᵢ") : rich("s", subscript("$i_s"))
			ax  = Axis(fig[i, j], 
				aspect=DataAspect(), 
				yreversed=true, 
				# xlabel=the_label,
				# xlabel=50
				# title="$sᵢ"
			)
			ylims!(ax, 0, size(img)[1]*1.5)
			image!(ax, reverse(img', dims=2))
			hidedecorations!(ax, label=false)
			hidespines!(ax)
			fontsize = Dict(1=> 85, 2=>65, 3=>60)
			text!(ax, size(img')[1]/2, size(img')[2]*1.25, text=the_label, 
				  fontsize=incl_data ? 50 : fontsize[n_rows], 
				  markerspace=:pixel,
				  align=(:center, :center), font=aog.firasans("light"))
		end
	end

	for j = 1:n_cols
		colsize!(fig.layout, j, Aspect(1, 1.5))
	end

	if incl_data
		ax2 = Axis(fig[n_rows+1, :], xticks=1:n, xticklabelsize=40, 
			alignmode=Outside(), xlabel="serial numbers", xlabelsize=40)
		hideydecorations!(ax2)
		hidespines!(ax2, :l)
		scatter!(ax2, s, zeros(length(s)), overdraw=true, 
			marker='↓', markersize=45,
			color=colors["data"], label=rich("data, s", superscript("(k=$k)"))
		)
		xlims!(ax2, 0.5, n+0.5)
		ylims!(ax2, -1.1, 1)
		rowsize!(fig.layout, n_rows+1, Relative(0.41 / n_rows + (n_rows - 1) *0.014))
	end
	resize_to_layout!(fig)
	if ! isnothing(savename)
		save("$savename.pdf", fig)
	end
	fig
end

# ╔═╡ e6fcc9c3-30d3-4287-ac82-36af58758778
viz_tank_capture(s, savename="paper/the_sample")

# ╔═╡ eb6d096d-754c-462b-be20-139433ef17f4
viz_tank_capture(s; incl_data=false, incl_realization=false)

# ╔═╡ 10b97dab-9e2d-4330-9fe7-e79e98f3d8fa
viz_tank_capture([1 for i = 1:6]; incl_data=false, incl_realization=false, n_rows=2)

# ╔═╡ 3d30e7c9-ac7a-496c-968c-9cc08dcc0568
viz_tank_capture([1 for i = 1:9]; incl_data=false, incl_realization=false, n_rows=3)

# ╔═╡ d3f5c14d-7692-41a4-aad1-d1eb18aa616c
md"## the prior
"

# ╔═╡ 5dcd6be3-8ba8-4995-833f-e39415bca1ca
md"upper bound on no. of tanks"

# ╔═╡ c9cbbd58-d5ff-4c15-9fda-d8f3b9ddbeb0
Ω = 35

# ╔═╡ ef605eff-89b9-4983-9208-2f15f4a5c8ec
viz_over_Ω = 5

# ╔═╡ a79630e6-61c1-425e-a43b-ff010d3ea14f
function prior(n, Ω)
	if (n <= Ω)
		return 1 / (Ω + 1)
	else
		return 0.0
	end
end

# ╔═╡ 9b895c1d-091e-4ce0-b4fc-4bdf9e0ac568
function viz_prior(Ω)
	fig = Figure()
	ax  = Axis(fig[1, 1], 
		xlabel=the_xlabel, 
		ylabel=rich("π", subscript("prior"), "(N=n)") 
		#title="prior distribution"
	)
	ns = 0:Ω+viz_over_Ω
	ps = [prior(n, Ω) for n in ns]
	println("sum = ", sum(ps))
	stem!(ax, ns, ps,
		trunkcolor="black", stemcolor=colors["prior"], color=colors["prior"],
		label="prior", marker=markers["prior"]
	)
	# ylims!(0, nothing)
	xlims!(-0.6, Ω+viz_over_Ω+0.5)
	save("paper/prior.pdf", fig)
	fig
end

# ╔═╡ 7b33b369-ca39-4261-b919-1c75bf59004b
viz_prior(Ω)

# ╔═╡ 005cd738-14f3-4852-9200-66c202f69e33
md"## the likelihood"

# ╔═╡ dbd34ed6-b37f-4f08-bc49-be91845c9347
begin
	falling_factorial(n::Int, k::Int) = factorial(n, n - k)
	# 5 tanks, choose 3 tanks, order matters.
	@assert falling_factorial(5, 3) == 5 * 4 * 3
end

# ╔═╡ ae3ed475-095f-42ae-9542-e1e83f1a3871
# π(m | n, k)
function likelihood(m::Int, n::Int, k::Int)
	if (k <= m) && (m <= n)
		return k * falling_factorial(m-1, k-1) / falling_factorial(n, k)
	else
		return 0.0
	end
end

# ╔═╡ 21a1ac93-f5dd-401d-923e-ab9877816470
function viz_likelihood(m, k; for_paper=true)
	fig = Figure()
	ax  = Axis(fig[1, 1], 
		xlabel=the_xlabel,
		ylabel=for_paper ? rich("π", subscript("likelihood"), "(M", 
			superscript("(k=$k)"), "=$m | N=n)") : 
		rich("π", subscript("likelihood"), "((S₁, S₂, S₃) = ($(s[1]), $(s[2]), $(s[3])) | N=n)")
		#title="likelihood"
	)
	ns = 0:Ω+viz_over_Ω
	stem!(ns, [likelihood(m, n, k) for n in ns],
		trunkcolor="black", stemcolor=colors["likelihood"], color=colors["likelihood"], marker=markers["likelihood"])
	# ylims!(0, nothing)
	xlims!(-0.5, maximum(ns)+0.5)
	save("paper/likelihood" * (for_paper ? "" : "_presentation") * ".pdf", fig)
	fig
end

# ╔═╡ 63e03cda-3f41-4eb6-8e4d-83f6eb4ec425
viz_likelihood(m, k)

# ╔═╡ 5b6514b7-7979-49ce-ba8c-7bf02849a119
viz_likelihood(m, k, for_paper=false) # for my presentation

# ╔═╡ 008e3d32-51c1-41c3-b0a9-3bb27601104e
md"## the posterior
first, the direct route from the paper
"

# ╔═╡ 2eaa8ef0-ae94-4b12-befc-57c6c06c285b
function direct_posterior(n, m, Ω, k)
	if (n >= m) && (n <= Ω)
		# note: this can handle larger numbers than using falling_factorial
		return 1 / binomial(n, k) / sum(1 / binomial(j, k) for j = m:Ω)
	else
		return 0.0
	end
end

# ╔═╡ 8be04e01-983b-40d4-b89f-1455a6c908c8
@assert direct_posterior(n, m, Ω, k) ≈ 1 / falling_factorial(n, k) / sum(1 / falling_factorial(j, k) for j = m:Ω)

# ╔═╡ 7bf30ec8-2327-4730-bf9a-9f44ff90142d
md"second, the indirect route by using the likelihood of m"

# ╔═╡ f4770f18-9e94-443b-9867-d9a960cd6518
# well, this is proportional to the posterior...
prop_to_posterior(n, m, Ω, k) = likelihood(m, n, k) * prior(n, Ω)

# ╔═╡ aed63250-fcd5-41f0-ab41-50470015c81e
evidence(m, Ω, k) = sum(prop_to_posterior(n, m, Ω, k) for n = k:Ω)

# ╔═╡ 4305f818-6211-4f07-9b6f-b44a22bf81cb
indirect_posterior(n, m, Ω, k) = prop_to_posterior(n, m, Ω, k) / evidence(m, Ω, k)

# ╔═╡ 3a8a23c0-63d4-4f1f-879d-d23c6d847664
@assert indirect_posterior(n, m, Ω, k) ≈ direct_posterior(n, m, Ω, k)

# ╔═╡ 002358ca-3ca0-484a-97e8-dc3b74d8e43f
md"does it normalize?"

# ╔═╡ 3b214065-a03e-4c91-af04-5923186c68f7
@assert sum(indirect_posterior(n, m, Ω, k) for n = m:Ω) ≈ 1.0

# ╔═╡ 8f9d2996-8483-458c-9899-17d4aa3de83b
@assert sum(direct_posterior(n, m, Ω, k) for n = m:Ω) ≈ 1.0

# ╔═╡ 7b27a6fd-57e8-4213-b8fc-1bddb829bc21
function build_credibility(m, Ω, k)
	credibility = DataFrame(n=0:Ω+10)
	credibility[:, "posterior prob"] = map(n -> direct_posterior(n, m, Ω, k), 
		                                   credibility[:, "n"])
	credibility[:, "prob ≥ n"] = zeros(nrow(credibility))
	credibility[:, "prob ≤ n"] = zeros(nrow(credibility))
	for i = 1:nrow(credibility)
		ids_geq = credibility[:, "n"] .>= credibility[i, "n"]
		ids_leq = credibility[:, "n"] .<= credibility[i, "n"]
		credibility[i, "prob ≥ n"] = sum(credibility[ids_geq, "posterior prob"])
		credibility[i, "prob ≤ n"] = sum(credibility[ids_leq, "posterior prob"])
	end
	return credibility
end

# ╔═╡ 903f3c2b-3d84-46a4-8378-e2eeb28744f3
md"### viz"

# ╔═╡ e02c3fe0-55a2-4ee9-b7f3-14f2349018ec
function prior_max_label!(fig, Ω::Int, i::Int)
	label_Ω = rich("n", subscript("max"), "=$Ω")
	Label(fig[i, 1], label_Ω, 
		tellwidth=false, tellheight=false, halign=0.95, valign=0.95, font=aog.firasans("Light"))
end

# ╔═╡ b27dc8e3-6240-46f2-83da-4b9187282ec9
credibility = build_credibility(m, Ω, k)

# ╔═╡ ba23b053-1907-4610-932e-f9be34c8b666
md"does it normalize?"

# ╔═╡ 797304f5-6151-4d30-8e67-ad2160ff030b
@assert sum(credibility[:, "posterior prob"]) ≈ 1.0

# ╔═╡ 71ce3211-8735-48a7-9c92-4d239b0a57b5
md"### summarizing the posterior

mean"

# ╔═╡ 026076e4-9690-4c3b-bdae-dc5689780d4f
n̄ = sum(credibility[i, "n"] * credibility[i, "posterior prob"] for i = 1:nrow(credibility))

# ╔═╡ 7ef952b7-c538-4153-aa78-e515c319c847
m + m/k-1 # frequentist

# ╔═╡ 1c0a7116-9a7b-4b52-ab5b-60c48f29d101
(m-1) * (k-1) / (k-2) # bayesian with improper prior

# ╔═╡ 6b44fe06-5346-4762-a41a-68cf642170f8
md"median"

# ╔═╡ 10420664-e886-47e1-8255-a50bea100322
"p-quantile is the smallest tank population size such that at least a proportion p of the mass sits on tank population sizes less than or equal to it"
function get_quantile(p::Float64, credibility::DataFrame)
	row = filter(row -> (row["prob ≥ n"] >= 1 - p) && (row["prob ≤ n"] >= p), credibility)
	@assert nrow(row) == 1
	return row
end

# ╔═╡ d1a20482-74d2-4530-8324-ace9b8bf6f23
get_quantile(0.5, credibility) # median

# ╔═╡ 7f8edf31-aa48-4f07-92ab-9b7aef71d385
credibility

# ╔═╡ c628b283-906d-4745-bf8c-7e252c7e5323
md"90% confidence interval"

# ╔═╡ 84c7ec4f-b454-4500-80d4-35634cd3003d
get_quantile(0.1, credibility)

# ╔═╡ 99cece15-e359-4bdf-86cc-3439b20a6027
md"wut's the probability the tank pop size is greater than n′?"

# ╔═╡ 2b974565-d92f-43fd-a9fa-e54d8eeff3c4
begin
	n′ = 30
	
	sum(credibility[i, "posterior prob"] for i = 1:nrow(credibility) if credibility[i, "n"] > n′)
end

# ╔═╡ eb5cc25e-971a-42ab-b168-609d502f3ea0
@warn "only works for uniform..."

# ╔═╡ d132dedf-a2c7-4f3f-b8e1-cdb75758d3f9
md"hdr"

# ╔═╡ a788b416-52ae-42f0-a465-43917c9b816a
function calc_hdr(credibility::DataFrame, m, Ω, k; α=0.2, verbose=true)
	# iteratively lower water levels 
	# (want to return largest one)
	for π_α in sort(credibility[:, "posterior prob"], rev=true)
		# set of n belonging to the HDR
		ns_hdr = [n̂ for n̂ = 0:Ω if direct_posterior(n̂, m, Ω, k) ≥ π_α]
		# mass contained in HDR
		mass_contained = sum(direct_posterior(n̂, m, Ω, k) for n̂ in ns_hdr)
		# if this mass contains more than or equal to desired density, we got our π_α
		if mass_contained ≥ 1 - α
			if verbose
				@show π_α
				@show ns_hdr
				@show mass_contained
			end
			return ns_hdr
		end
	end
end

# ╔═╡ 626ff09d-0aee-4d54-a988-4734e728af45
function _viz_summary_posterior!(ax, m, Ω, k)
	credibility = build_credibility(m, Ω, k)
	hdr = calc_hdr(credibility, m, Ω, k)
	med = get_quantile(0.5, credibility)[1, "n"]

	for n_in_hdir in hdr
		vspan!(ax, n_in_hdir-0.25, n_in_hdir+0.25, color=(colors["posterior"], 0.1))
	end
	vlines!(ax, med, color=colors["posterior"], linewidth=1, linestyle=:dash)
end

# ╔═╡ 748eb45d-cfbc-4916-a621-be8eb290a9dc
function viz_posterior(m, Ω, k; savename::String="posterior", kwargs...)
	fig = Figure()
	ax  = Axis(fig[1, 1], 
		xlabel=the_xlabel,
		ylabel=rich("π", subscript("posterior"), "(N=n | M", 
			        superscript("(k = $k)"), "=$m)"
				   )
	)
	xmax = Ω+viz_over_Ω
	
	# viz_ci
	α = 0.2
	_viz_summary_posterior!(ax, m, Ω, k)
	ns = 0:xmax
	stem!(ax, ns, map(n -> direct_posterior(n, m, Ω, k), ns),
		trunkcolor="black", stemcolor=colors["posterior"], color=colors["posterior"],
		label="posterior", marker=markers["posterior"]
	)
	# ylims!(0, nothing)
	xlims!(ax, -0.5, xmax+0.5)
 	prior_max_label!(fig, Ω, 1)
	
	save("paper/$(savename)_$Ω.pdf", fig)
	return fig
end

# ╔═╡ 969e0a3f-c3d7-4604-8a8a-fcd3ee0f24fe
viz_posterior(m, Ω, k)

# ╔═╡ a91ce2cf-2904-477e-9095-d9d2ee5353fa
the_hdr = calc_hdr(credibility, m, Ω, k)

# ╔═╡ 0c4152e4-c82f-4801-9cf8-185eba05fe57
md"## viz all at once"

# ╔═╡ b1e45ddd-636c-4abe-bc37-3093c21aaebb
function _viz_all!(ax, m, Ω, k, xmax)
	ns = 0:xmax
	α = 0.2
	# manual trunk
	hlines!(0.0, color="black")
	# prior
	stem!(ax, ns, [prior(n, Ω) for n in ns],
		trunkcolor=("black", 0.0), stemcolor=(colors["prior"], α), color=colors["prior"], label="prior", marker=markers["prior"])
	# likelihood
	stem!(ax, ns, [likelihood(m, n, k) for n in ns],
		trunkcolor=("black", 0.0), stemcolor=(colors["likelihood"], α), color=colors["likelihood"], label="likelihood", marker=markers["likelihood"])
	# posterior
	stem!(ax, ns, [direct_posterior(n, m, Ω, k) for n in ns],
		trunkcolor=("black", 0.0), stemcolor=(colors["posterior"], α),
		color=colors["posterior"], label="posterior", marker=markers["posterior"])

	xlims!(ax, -1, maximum(ns)+0.5)
end

# ╔═╡ 472507c4-45a1-4567-9d9f-53bdb872ec1b
function viz_all(m, Ω, k)
	credibility = build_credibility(m, Ω, k)
	
	fig = Figure()
	ax  = Axis(fig[1, 1], 
		xlabel=the_xlabel,
		ylabel="probability"
	)
	_viz_all!(ax, m, Ω, k, Ω+viz_over_Ω)
	axislegend()
	save("paper/all.pdf", fig)
	fig
end

# ╔═╡ 02db6a13-f513-46ce-a351-b63f7fe0e95e
viz_all(m, Ω, k)

# ╔═╡ 5887cdcd-c06c-4226-8f94-9da336360da7
md"## sensitivity to prior"

# ╔═╡ c80f4f77-9ed5-41c8-9e54-ef048532950b
n_max_for_post_sensitivity = 80

# ╔═╡ 17b5d7a1-b5a2-4211-b81d-c88fbf0249e9
function viz_post_sensitivity_to_prior(m::Int, n_maxs::Vector{Int}, k::Int; 
		kwargs...)
	fig = Figure(resolution=(700, 800))
	axs = []
	for (i, n_max) in enumerate(n_maxs)
		ax = Axis(fig[i, 1])
		if i == 3
		    ax.xlabel=the_xlabel
		else
			hidexdecorations!(ax)
		end
		_viz_summary_posterior!(ax, m, n_max, k)
		_viz_all!(ax, m, n_max, k, 80)
		
		prior_max_label!(fig, n_max, i)
		if i == 1
			axislegend(position=:rc)
		end
	
		push!(axs, ax)
	end
	Label(fig[:, 0], 
		text="probability", 
		font=aog.firasans("Light"),
		rotation=π/2
	)
	linkyaxes!(axs...)
	linkxaxes!(axs...)
	save("paper/posterior_prior_sensitivity.pdf", fig)
	return fig
end

# ╔═╡ 037642de-baea-437f-b5fe-f947b9943334
begin
	n_maxes = [25, 50, 75]
	viz_post_sensitivity_to_prior(m, n_maxes, k)
end

# ╔═╡ 4a6e7740-b575-4f8b-8ae8-b5906ed5861c
md"## posterior checking"

# ╔═╡ 985882c0-66ec-4916-a0e5-375883999839
function check_posterior(m::Int, Ω::Int, k::Int, s::Vector{Int})
	@assert length(s) == k
	@assert maximum(s) == m
	
	ss = 1:Ω+viz_over_Ω
	prob_s = zeros(length(ss))
	for n = 0:Ω+viz_over_Ω
		# posterior prob of n
		p_n = direct_posterior(n, m, Ω, k)
		prob_s[1:n] .+= k/n * p_n
	end
	println("sum = ", sum(prob_s) / k)

	fig = Figure()
	ax  = Axis(fig[1, 1], xlabel="serial number, s̃", ylabel="probability")
	stem!(ss, prob_s,
		trunkcolor="black", stemcolor=colors["other"], color=colors["other"])
	xlims!(-0.5, maximum(ss)+0.5)
	# ylims!(0, nothing)
	# Label(fig[1, 1], rich("n", subscript("max"), "=$Ω"), 
	# 	tellwidth=false, tellheight=false, halign=0.95, valign=0.95, font=aog.firasans("Light"))
	# the data
	scatter!(s, -0.006 * ones(length(s)), overdraw=true, 
		marker='↑', markersize=20,
		color=colors["data"], label=rich("data, s", superscript("(k=$k)"))
	)
	axislegend(rich("n", subscript("max"), "=$Ω"))
	save("paper/posterior_check.pdf", fig)
	fig
end

# ╔═╡ dfb59e14-e175-470a-8bf3-47a543f2ef6c
check_posterior(m, Ω, k, s)

# ╔═╡ 97b842fc-baed-4cec-8954-a1974d2bfe4c
md"## more data..."

# ╔═╡ bfc2af36-5ace-4b7e-9b8d-3ee0ff724a78
begin
	Random.seed!(my_seed)
	k_new = 12
	s_new = sample_tanks(k_new, n)
	m_new = maximum(s_new)
	@show s_new
	@show m_new
end

# ╔═╡ ee79435d-7ac7-4534-b478-57509200b1ac
viz_tank_capture(s_new, savename="the_big_sample", n_rows=4)

# ╔═╡ 1efe634c-700e-4301-90c3-0731a4823608
viz_posterior(m_new, Ω, k_new, savename="posterior_big")

# ╔═╡ 710b3dc8-d9d3-4125-91eb-2758ca2080f7
md"## check prob of serial no."

# ╔═╡ 61efb66f-b026-4624-b658-62639b3ab6e4
mean([1 in sample_tanks(k, n) for _ = 1:1000000])

# ╔═╡ 7b0eb598-5d04-4cce-8c88-78fffae3fca9
k/n

# ╔═╡ fb51a872-8c60-4c51-b892-9e9d58e3eb7c
md"## simulations with known $n$"

# ╔═╡ af810a32-cf8c-49e1-901a-ef5784956cf0
ks = [5, 10, 15]

# ╔═╡ 534241be-7d5f-4ed5-82f4-97a9f8d5adff
n_maxes

# ╔═╡ 5b68efa8-182e-4b85-86cd-7c049db673fd
# entry i is prob i ∈ Hₐ.
function simulate_ci(n::Int, k::Int, Ω::Int; nb_sims::Int=1000)
	posterior_mass_on_n = zeros(80)
	meds = zeros(1:nb_sims)
	for s = 1:nb_sims
		# capture sample of tanks
		sᵏ = sample_tanks(k, n)
		
		# calculate maximum
		m = maximum(sᵏ)
		
		# determine posterior credibility, high density region, and median
		credibility = build_credibility(m, Ω, k)
		hdr = calc_hdr(credibility, m, Ω, k, verbose=false)
		med = get_quantile(0.5, credibility)[1, "n"]
		
		# store results
		meds[s] = med
		posterior_mass_on_n[hdr] .+= 1
	end
	posterior_mass_on_n /= nb_sims
	return posterior_mass_on_n, meds
end

# ╔═╡ cc165364-ee30-4b0c-b082-d7307a14e7db
function viz_ℋₐ(Ωs::Vector{Int}, ks::Vector{Int}; n::Int=20, nb_sims::Int=1000)
	# rows : ks
	# cols: n_maxes
	fig = Figure(resolution=(700, 700))
	axs = [Axis(fig[i, j]) for i = 1:length(ks), j = 1:length(ks)]
	axs[end, 2].xlabel = the_xlabel
	axs[2, 1].ylabel = "probability n ∈ ℋₐ"
	linkaxes!(axs[:]...)

	ss = 1:45
	for i = 1:length(ks)
		for j = 1:length(Ωs)
			if j != 1
				hideydecorations!(axs[i, j], ticks=false)
			end
			if i != length(Ωs)
				hidexdecorations!(axs[i, j], ticks=false)
			end
			
			posterior_mass_on_n, meds = simulate_ci(n, ks[i], Ωs[j], nb_sims=nb_sims)
			@show median(meds)
			
			stem!(axs[i, j], ss, posterior_mass_on_n[ss],
				  marker=markers["posterior"], markersize=10,
				  trunkcolor="black", stemcolor=colors["posterior"], 
				  color=colors["posterior"], stemwidth=1)
			ylims!(axs[i, j], -0.075, 1.01)
			vlines!(axs[i, j], median(meds), color="black", linewidth=1, linestyle=:dash, label="median")
			hlines!(axs[i, j], 1.0, linewidth=1, color="lightgray", linestyle=:dashdot)
			scatter!(axs[i, j], [n], [-0.05], overdraw=true, 
					marker='↑', markersize=20, color="red", label="n")
			xlims!(axs[i, j], 0, 44)
			if i == j == 1
				axislegend(axs[i, j], labelsize=16)
			end
		end
	end
	save("hdr_study.pdf", fig)
	return fig
end

# ╔═╡ 8440db62-bb3c-43e8-beab-d112caab1a76
begin
	my_ks = [3, 6, 9]
	my_Ωs = [25, 50, 100]
	viz_ℋₐ(my_Ωs, my_ks, nb_sims=50000)
end

# ╔═╡ 1edf0621-bc43-432c-86fa-0bf5671d0b65
function mini_prior(Ω::Int)
	ns = 0:105
	ps = [prior(n, Ω) for n in ns]
	
	fig = Figure(resolution=(700/3, 700/3))
	ax_p = Axis(fig[1, 1], xlabel="n", ylabel=rich("π", subscript("prior"), "(N=n)") )
	stem!(ax_p, ns, ps, stemwidth=0.5,
		trunkcolor="black", markersize=5, 
		stemcolor=colors["prior"], color=colors["prior"],
		marker=markers["prior"])
	xlims!(-1, 106)
	hideydecorations!(ax_p, label=false)
	ylims!(-0.045*0.03, 0.045)
	save("mini_prior_$Ω.pdf", fig)
	return fig
end

# ╔═╡ 0f0fd79b-ced3-40af-baef-d62f46f108dc
[mini_prior(Ω) for Ω in my_Ωs]

# ╔═╡ cb5eae01-c98b-468c-99eb-5e8973328d90
[viz_tank_capture([1 for i = 1:k], 
	incl_data=false, 
	incl_realization=false, 
	n_rows=Int(k/3), 
	savename="generic_tank_capture_$k"
) for k in my_ks]

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
AlgebraOfGraphics = "~0.6.14"
CairoMakie = "~0.10.2"
Combinatorics = "~1.0.2"
DataFrames = "~1.5.0"
FileIO = "~1.16.0"
PlutoUI = "~0.7.50"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "391c26490f94108728d95bc5038eaeb1acbf68f7"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "0310e08cb19f5da31d08341c6120c047598f5b9c"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.5.0"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "SnoopPrecompile", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "43c2ef89ca0cdaf77373401a989abae4410c7b8a"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.14"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "1dd4d9f5beebac0c03446918741b1a03dc5e5788"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.6"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "SnoopPrecompile"]
git-tree-sha1 = "abb7df708fe1335367518659989627100a61f3f0"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.10.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "9258430c176319dc882efa4088e2ff882a0cb1f1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.81"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "d3ba08ab64bdfd27234d3f61956c966266757fe6"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "38a92e40157100e796690421e34a11c107205c86"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "884477b9886a52a84378275737e2823a5c98e349"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.8.1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "1cd7f0af1aa58abc02ea1d872953a97359cb87fa"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.4"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "e07a1b98ed72e3cdd02c6ceaab94b8a606faca40"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.2.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "fe9aea4ed3ec6afdfbeb5a4f39a2208909b162a6"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.5"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "678d136003ed5bceaab05cf64519e3f956ffa4ba"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "16c0cc91853084cb5f58a78bd209513900206ce6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "106b6aa272f294ba47e96bd3acbabdc0407b5c60"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "MiniQhull", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Setfield", "Showoff", "SignedDistanceFields", "SnoopPrecompile", "SparseArrays", "StableHashTraits", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "274fa9c60a10b98ab8521886eb4fe22d257dca65"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.19.2"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "2c3fc86d52dfbada1a2e5e150e50f06c30ef149c"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.6.2"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test", "UnicodeFun"]
git-tree-sha1 = "f04120d9adf4f49be242db0b905bea0be32198d1"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.4"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.MiniQhull]]
deps = ["QhullMiniWrapper_jll"]
git-tree-sha1 = "9dc837d180ee49eeb7c8b77bb1c860452634b0d1"
uuid = "978d7f02-9e05-4691-894f-ae31a51d76ca"
version = "0.4.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "5ae7ca23e13855b3aba94550f26146c01d259267"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "6862738f9796b3edc1c09d0890afce4eca9e7e93"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.4"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "82d7c9e310fe55aa54996e6f7f94674e2a38fcb4"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.9"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "ec3edfe723df33528e085e632414499f26650501"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6f4fbcd1ad45905a5dee3f4256fabb49aa2110c6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.7"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "c95373e73290cf50a8a22c3375e4625ded5c5280"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.4"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QhullMiniWrapper_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Qhull_jll"]
git-tree-sha1 = "607cf73c03f8a9f83b36db0b86a3a9c14179621f"
uuid = "460c41e3-6112-5d7f-b78c-b6823adb3f2d"
version = "1.0.0+1"

[[deps.Qhull_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "238dd7e2cc577281976b9681702174850f8d4cbc"
uuid = "784f63db-0788-585a-bace-daefebcd302b"
version = "8.0.1001+0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "786efa36b7eff813723c4849c90456609cf06661"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "8b20084a97b004588125caebf418d8cab9e393d1"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.4"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "77d3c4726515dca71f6d80fbb5e251088defe305"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.18"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "503688b59397b3307443af35cd953a13e8005c16"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "2.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StableHashTraits]]
deps = ["CRC32c", "Compat", "Dates", "SHA", "Tables", "TupleTools", "UUIDs"]
git-tree-sha1 = "0b8b801b8f03a329a4e86b44c5e8a7d7f4fe10a3"
uuid = "c5dd0088-6c3f-4803-b00e-f31a60c170fa"
version = "0.3.1"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "2d7d9e1ddadc8407ffd460e24218e37ef52dd9a3"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.16"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "ab6083f09b3e617e34a956b43e9d51b824206932"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.1.1"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "a5e15f27abd2692ccb61a99e0854dfb7d48017db"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.33"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "b03a3b745aa49b566f128977a7dd1be8711c5e71"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.14"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "7e6b0e3e571be0b4dd4d2a9a3a83b65c04351ccc"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.3"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.TupleTools]]
git-tree-sha1 = "3c712976c47707ff893cf6ba4354aa14db1d8938"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.3.0"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╠═f51509b6-6c25-11ed-371e-35df2270ac8a
# ╠═aed174c4-d5fb-459c-b9b7-1e0ebc17be0d
# ╟─21575264-8b5a-4c6b-b6ff-c2f29f76c26b
# ╠═8d134dd1-7a6f-4f58-b555-7fcfe4210177
# ╠═9e831714-3ce5-4b68-83f3-e98384732554
# ╠═90816107-f479-4727-b8e9-405825c7c68f
# ╠═08404a85-ca12-4a6c-a3b5-733e1e1d61e0
# ╠═df4fb49d-f060-4063-a1d7-de6568d3eb53
# ╟─b09ad25f-436a-49fc-9304-5e59573c7ccd
# ╠═fc649f6d-223d-408a-ad4e-c8b93cfaa661
# ╟─8255eb75-fa6b-4e8f-9d1e-c40192009e4e
# ╠═4482a867-ae1f-4a82-bfd7-a826e61ccfbb
# ╟─57115caa-0c68-461e-968f-7ac206739f7a
# ╠═fb9a152f-ac8d-46f7-b061-3436a72fb4bd
# ╟─a8ad008a-14da-4032-af42-4a65e6cf598b
# ╠═cb3c96da-4678-44bf-b149-1e13b22804e8
# ╟─d563bdd8-4a22-417a-93ab-79cbbc0b7d8f
# ╠═3d29f507-918e-4ca4-8265-51cb1efbfc24
# ╠═1c4f3910-29dd-447d-9c18-0f2b1bc190eb
# ╠═e6fcc9c3-30d3-4287-ac82-36af58758778
# ╠═eb6d096d-754c-462b-be20-139433ef17f4
# ╠═10b97dab-9e2d-4330-9fe7-e79e98f3d8fa
# ╠═3d30e7c9-ac7a-496c-968c-9cc08dcc0568
# ╟─d3f5c14d-7692-41a4-aad1-d1eb18aa616c
# ╟─5dcd6be3-8ba8-4995-833f-e39415bca1ca
# ╠═c9cbbd58-d5ff-4c15-9fda-d8f3b9ddbeb0
# ╠═ef605eff-89b9-4983-9208-2f15f4a5c8ec
# ╠═a79630e6-61c1-425e-a43b-ff010d3ea14f
# ╠═9b895c1d-091e-4ce0-b4fc-4bdf9e0ac568
# ╠═7b33b369-ca39-4261-b919-1c75bf59004b
# ╟─005cd738-14f3-4852-9200-66c202f69e33
# ╠═dbd34ed6-b37f-4f08-bc49-be91845c9347
# ╠═ae3ed475-095f-42ae-9542-e1e83f1a3871
# ╠═21a1ac93-f5dd-401d-923e-ab9877816470
# ╠═63e03cda-3f41-4eb6-8e4d-83f6eb4ec425
# ╠═5b6514b7-7979-49ce-ba8c-7bf02849a119
# ╟─008e3d32-51c1-41c3-b0a9-3bb27601104e
# ╠═2eaa8ef0-ae94-4b12-befc-57c6c06c285b
# ╠═8be04e01-983b-40d4-b89f-1455a6c908c8
# ╟─7bf30ec8-2327-4730-bf9a-9f44ff90142d
# ╠═f4770f18-9e94-443b-9867-d9a960cd6518
# ╠═aed63250-fcd5-41f0-ab41-50470015c81e
# ╠═4305f818-6211-4f07-9b6f-b44a22bf81cb
# ╠═3a8a23c0-63d4-4f1f-879d-d23c6d847664
# ╟─002358ca-3ca0-484a-97e8-dc3b74d8e43f
# ╠═3b214065-a03e-4c91-af04-5923186c68f7
# ╠═8f9d2996-8483-458c-9899-17d4aa3de83b
# ╠═7b27a6fd-57e8-4213-b8fc-1bddb829bc21
# ╟─903f3c2b-3d84-46a4-8378-e2eeb28744f3
# ╠═e02c3fe0-55a2-4ee9-b7f3-14f2349018ec
# ╠═626ff09d-0aee-4d54-a988-4734e728af45
# ╠═748eb45d-cfbc-4916-a621-be8eb290a9dc
# ╠═969e0a3f-c3d7-4604-8a8a-fcd3ee0f24fe
# ╠═b27dc8e3-6240-46f2-83da-4b9187282ec9
# ╟─ba23b053-1907-4610-932e-f9be34c8b666
# ╠═797304f5-6151-4d30-8e67-ad2160ff030b
# ╟─71ce3211-8735-48a7-9c92-4d239b0a57b5
# ╠═026076e4-9690-4c3b-bdae-dc5689780d4f
# ╠═7ef952b7-c538-4153-aa78-e515c319c847
# ╠═1c0a7116-9a7b-4b52-ab5b-60c48f29d101
# ╟─6b44fe06-5346-4762-a41a-68cf642170f8
# ╠═10420664-e886-47e1-8255-a50bea100322
# ╠═d1a20482-74d2-4530-8324-ace9b8bf6f23
# ╠═7f8edf31-aa48-4f07-92ab-9b7aef71d385
# ╟─c628b283-906d-4745-bf8c-7e252c7e5323
# ╠═84c7ec4f-b454-4500-80d4-35634cd3003d
# ╟─99cece15-e359-4bdf-86cc-3439b20a6027
# ╠═2b974565-d92f-43fd-a9fa-e54d8eeff3c4
# ╟─eb5cc25e-971a-42ab-b168-609d502f3ea0
# ╟─d132dedf-a2c7-4f3f-b8e1-cdb75758d3f9
# ╠═a788b416-52ae-42f0-a465-43917c9b816a
# ╠═a91ce2cf-2904-477e-9095-d9d2ee5353fa
# ╟─0c4152e4-c82f-4801-9cf8-185eba05fe57
# ╠═b1e45ddd-636c-4abe-bc37-3093c21aaebb
# ╠═472507c4-45a1-4567-9d9f-53bdb872ec1b
# ╠═02db6a13-f513-46ce-a351-b63f7fe0e95e
# ╟─5887cdcd-c06c-4226-8f94-9da336360da7
# ╠═c80f4f77-9ed5-41c8-9e54-ef048532950b
# ╠═17b5d7a1-b5a2-4211-b81d-c88fbf0249e9
# ╠═037642de-baea-437f-b5fe-f947b9943334
# ╟─4a6e7740-b575-4f8b-8ae8-b5906ed5861c
# ╠═985882c0-66ec-4916-a0e5-375883999839
# ╠═dfb59e14-e175-470a-8bf3-47a543f2ef6c
# ╟─97b842fc-baed-4cec-8954-a1974d2bfe4c
# ╠═bfc2af36-5ace-4b7e-9b8d-3ee0ff724a78
# ╠═ee79435d-7ac7-4534-b478-57509200b1ac
# ╠═1efe634c-700e-4301-90c3-0731a4823608
# ╟─710b3dc8-d9d3-4125-91eb-2758ca2080f7
# ╠═61efb66f-b026-4624-b658-62639b3ab6e4
# ╠═7b0eb598-5d04-4cce-8c88-78fffae3fca9
# ╟─fb51a872-8c60-4c51-b892-9e9d58e3eb7c
# ╠═af810a32-cf8c-49e1-901a-ef5784956cf0
# ╠═534241be-7d5f-4ed5-82f4-97a9f8d5adff
# ╠═5b68efa8-182e-4b85-86cd-7c049db673fd
# ╠═cc165364-ee30-4b0c-b082-d7307a14e7db
# ╠═8440db62-bb3c-43e8-beab-d112caab1a76
# ╠═1edf0621-bc43-432c-86fa-0bf5671d0b65
# ╠═0f0fd79b-ced3-40af-baef-d62f46f108dc
# ╠═cb5eae01-c98b-468c-99eb-5e8973328d90
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
