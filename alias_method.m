%% Generates random samples from a discrete probability distribution.
%
%  Uses the "Alias-method", see [1,2,3].
%
% ARGUMENTS: 
%    discrete_distribution -- a column vector containing the probabilities for
%                             each element in the discrete distribution.
%                             NOTE: if not column, conversion done internally.
%    discrete_values -- a column vector of the values to which the probability
%                       entries correspond. Must have the same number of entries
%                       as the first argument. If this is not provided then the
%                       returned draw_samples() function returns randomly sampled
%                       indices into the discrete distribution.
%                       NOTE: if not column, conversion done internally.
%    seed -- set the state of the random-number-generator, for a reproducible
%            draw function.
%            NOTE: this MUST be set if you want to generate reproducible results.
%
% OUTPUT:
%    draw_samples -- a function handle that can be used to sample the distribution.
%                    NOTE: if alias_method() is called with one argument then this
%                    function returns indices into the distribution; if alias_method()
%                    is called with two arguments then this function returns randomly
%                    sampled data from the distribution.
%        Arguments to draw_samples():
%            number_of_samples -- number of samples to draw from the discrete distribution.
%            seed -- set the state of the random-number-generator, for reproducible sequences.
%                    NOTE: For a given realisation of the draw_samples() function,
%                          draw_samples(1024, 42) == [draw_samples(512, 42) ; draw_samples(512)].
%        Output of draw_samples():
%            samples -- a column vector of samples drawn randomly from the
%                       discrete distribution. Whether these are indices into
%                       that distribution or values depends on how alias_method()
%                       was called, see description of discrete_values above.
%
%    %NOTE: the following return values are primarily for debugging purposes and may be removed...
%    alias_table -- The alias table used internally.
%    probability_table -- The probability table used internally.
%    number_of_values -- number of values in the initial discrete distribution.
%
%
% REFERENCES:
%     [1] https://en.wikipedia.org/wiki/Alias_method
%     [2] http://keithschwarz.com/darts-dice-coins/
%     [3] Knuth, Art of Computer Programming, Vol. 2 (3rd Ed): Seminumerical Algorithms: Sect. 3.4.1.
%
%
% AUTHOR:
%     Stuart A. Knock (2018-03-05).
%
% USAGE:
%{
    %% Simple data example
    simple_data = [4; 4; 2; 2; 2; 2; 3; 1; 5; 6];
    [prob_sd, prob_sd_edges] = histcounts(simple_data, 'Normalization', 'probability');
    prob_sd_centres = prob_sd_edges(1:(end-1)) + (diff(prob_sd_edges) ./ 2.0);
    figure
    histogram(simple_data, prob_sd_edges, 'Normalization', 'probability')
    title('Original Simple Data')
    [draw_sd] = alias_method(prob_sd, prob_sd_centres);
    figure
    histogram(draw_sd(131072), prob_sd_edges, 'Normalization', 'probability')
    title('Random Sample Simple Data Probability')


    %% Big Gaussian data example, with exact reproduction for method and sequence.
    % Create a test dataset
    source_sample_count = 65536;
    rnx = randn(source_sample_count, 1);

    %% Turn data into a discrete probability distribution, get edges and centres.
    [prob_rnx, prob_rnx_edges] = histcounts(rnx, 128, 'Normalization', 'probability');
    prob_rnx_centres = prob_rnx_edges(1:(end-1)) + (diff(prob_rnx_edges) ./ 2.0);

    %% Plot original data's distribution
    figure, histogram(rnx, prob_rnx_edges), title('Original Distribution')

    %% Called with one arg, the draw function will return indices into the probability distribution.
    [draw_rnx_ind] = alias_method(prob_rnx, [], 42);
    figure
    histogram(prob_rnx_centres(draw_rnx_ind(source_sample_count, 42)), prob_rnx_edges)
    title('Random Sample by Index Distribution')

    %% Called with two args, the draw function will return randomly sampled data.
    [draw_rnx] = alias_method(prob_rnx, prob_rnx_centres, 42);
    figure
    histogram(draw_rnx(source_sample_count, 42), prob_rnx_edges)
    title('Random Sample by Value Distribution')

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [draw_samples, alias_table, probability_table, number_of_values] = alias_method(discrete_distribution, discrete_values, seed)
    if nargin < 1 || isempty(discrete_distribution)
        error(['SAK:' mfilename ':NoDistribution'], ...
               'You must specify discrete-distribution to be sampled.');
    elseif ~iscolumn(discrete_distribution)
        % Ensure size is (n,1), so draw_samples() returns a column vector.
        discrete_distribution = discrete_distribution(:);
    end
    if nargin < 2 || isempty(discrete_values)
        discrete_values = [];
    elseif numel(discrete_distribution) ~= numel(discrete_values)
        error(['SAK:' mfilename ':BadSize'], ...
               'The discrete-distribution and discrete-values vectors must have the same number of elements.');
    elseif ~iscolumn(discrete_values)
        % Ensure size is (n,1), so draw_samples() returns a column vector.
        discrete_values = discrete_values(:);
    end

    %% Do some basic tests of the discrete-distribution we were provided.
    % Do not allow negative "probability" entries, there is no sensible way to handle them.
    if any(discrete_distribution < 0.0)
        error(['SAK:' mfilename ':BadDistribution'], ...
               'The discrete-distribution to be sampled must all be >=0.0.');
    end
    % Following the "must not be negative" above, this excludes all entries being either 0.0 or NaN.
    if ~any(discrete_distribution > 0.0)
        error(['SAK:' mfilename ':NoData'], ...
                'The discrete-distribution to be sampled contains no data.');
    end
    % Treat NaN as 0.0
    dd_nan_mask = isnan(discrete_distribution);
    if any(dd_nan_mask)
        discrete_distribution(dd_nan_mask) = 0.0;
    end
    clear dd_nan_mask
    %TODO: consider extra checks...

    if nargin > 2 && ~isempty(seed)
        % Capture current state of the random number generator.
        initial_rand_state = rng;
        % Set the random number generator state based on caller provided seed.
        rng(seed);
    end

    %% Declare function handle so we can return the function that we define below.
    draw_samples = @draw_samples_from_distribution;

    %% Make sure the discrete-distribution is a probability distribution, ie sum to 1.
    sum_dd = sum(discrete_distribution);
    if sum_dd ~= 1.0
        discrete_distribution = discrete_distribution / sum_dd;
    end

    %% Initialise the main variables that will be used by the returned function.
    number_of_values = numel(discrete_distribution); %Number-of-values in the discrete distribution.
    probability_table = number_of_values * discrete_distribution;
    alias_table = nan(number_of_values, 1);

    %% Categorise the probability-table entries.
    overfull = probability_table > 1.0;
    underfull = probability_table < 1.0;
    exactly_full = probability_table == 1.0;

    % Already exactly-full entries will not be updated, so we set them to their index.
    alias_table(exactly_full) = find(exactly_full);

    while any(underfull) && any(overfull)
        %NOTE: By construction, if there is an overfull entry there must be an underfull one.
        %% Randomly select one overfull and one under-full index.
        uf = find(underfull);
        of = find(overfull);
        uf_index = uf(randperm(numel(uf), 1)); % Index of an underfull entry.
        of_index = of(randperm(numel(of), 1)); % Index of an overfull entry.

        alias_table(uf_index) = of_index; %Allocate the unused space in entry uf_index to outcome of_index.
        probability_table(of_index) = probability_table(of_index) + probability_table(uf_index) - 1.0; % Remove the allocated space from entry of_index.

        underfull(uf_index) = false;
        exactly_full(uf_index) = true; %

        % Re-categorise the updated probability_table entry.
        overfull(of_index) = false;
        if probability_table(of_index) > 1.0
            overfull(of_index) = true;
        elseif probability_table(of_index) < 1.0
            underfull(of_index) = true;
        else
            exactly_full(of_index) = true;
        end
    end % while any(underfull) && any(overfull)

%TODO: the following rounding-error correction has the potential to hide any bug
%      in the above algorithm, it should be evaluated more thoroughly, we don't
%      want it hiding actual errors.
% if any(probability_table(isnan(alias_table)) < 1)
%     keyboard
% end

    %NOTE: Having probability_table < 1 with no alias_table entry can cause a
    %      problem with the choice to use the alias_table in the draw function.
    %      To avoid this possibility we round any remaining overfull or
    %      underfull entries to 1.0. When everything is working correctly there
    %      should be only either overfull or underfull, but not both. Furthermore,
    %      the underfull values should be ~0.999??? and the overfull ~1.000???,
    %      from some quick tests, rounding error seems to be ~< 1.0e-13, so, it's
    %      a very small probability problem we're correcting for here.

    % Clean-up any accumulated rounding error, see NOTE above for details.
    final_uf = find(underfull);
    final_of = find(overfull);
    if ~isempty(final_of)
        %NOTE: Enable the following to check the correction isn't hiding any bugs.
        % fprintf('final_of: "%s".\n', num2str(final_of))
        % fprintf('probability_table(final_of): "%s".\n', num2str(probability_table(final_of), 16))
        % fprintf('abs(probability_table(final_of) - 1.0): "%s".\n', num2str(abs(probability_table(final_of) - 1.0), 16))
        probability_table(final_of) = 1.0; %round(probability_table(final_of));
    elseif ~isempty(final_uf)
        %NOTE: Enable the following to check the correction isn't hiding any bugs.
        % fprintf('final_uf: "%s".\n', num2str(final_uf))
        % fprintf('probability_table(final_uf): "%s".\n', num2str(probability_table(final_uf), 16))
        % fprintf('abs(probability_table(final_uf) - 1.0): "%s".\n', num2str(abs(probability_table(final_uf) - 1.0), 16))
        probability_table(final_uf) = 1.0; %round(probability_table(final_uf));
    end

    % Initialise a variable containing the current random state, used to enable reproducible sequences.
    current_rand_state = rng;

    if nargin > 2 && ~isempty(seed)
        % Reset the state of the random number generator to what it was when we were called.
        rng(initial_rand_state);
    end

    %% Clear temporary stuff from above from the name-space, so our draw_samples() function isn't carrying around unnecessary cruft
    clear discrete_distribution sum_dd overfull underfull exactly_full uf of uf_index of_index final_uf final_of seed initial_rand_state


    %% Define the function for drawing samples from the provided distribution.
    function [samples] = draw_samples_from_distribution(number_of_samples, seed)
        % Capture current state of the random number generator.
        initial_rand_state = rng;
        if nargin > 1 && ~isempty(seed)
            % Set the random number generator state based on caller provided seed.
            rng(seed);
        else
            % Set the random number generator state it had at the end of the last call.
            rng(current_rand_state)
        end

        % Initialise our return value.
        samples = nan(number_of_samples, 1);

        % Draw a sequence of uniform random numbers.
        uniform_variate = rand(size(samples)); %NOTE: rand() returns open interval (0,1), ie excludes both 0 and 1.

        %TODO: this algorithm actually assumes uniform_variate = [0,1), ie 0<= uniform_variate < 1, but rand() returns (0,1)...
        %      however, as the probability of hitting 0 in a random draw in the [0,1) case would be in the range 2^-53 to 2^-64 it probably ;-) isn't worth it...
        % % Draw a sequence of random numbers in a closed-open interval[0,1), ie with 0 <= x < 1.
        % uniform_variates = co_rand(size(samples));

        % Select random indices into the discrete probability-distribution.
        random_table_index = floor(number_of_values * uniform_variate) + 1; %uniform-random samples from {1,2,...,number_of_values}

        % Calculate the threshold for selecting between probability-table and alias-table.
        uniform_index_remainder = (number_of_values * uniform_variate) + 1 - random_table_index;

        % Create a mask to determine whether to return samples based on probability-table or alias-table.
        mask_prob_or_alias = uniform_index_remainder <  probability_table(random_table_index);

        % Set sample indices based on probability-table.
        samples(mask_prob_or_alias) = random_table_index(mask_prob_or_alias);
        % Set sample indices based on alias-table
        samples(~mask_prob_or_alias) = alias_table(random_table_index(~mask_prob_or_alias));

        % If values that the probabilities correspond to were provided, do the mapping.
        if ~isempty(discrete_values)
            samples = discrete_values(samples);
        end

        % Update the variable containing the current random state, so calling,
        % for example, draw_samples_from_distribution(512) twice produces the
        % same sequence as calling draw_samples_from_distribution(1024).
        current_rand_state = rng;

        % Reset the state of the random number generator to what it was when we were
        % called, so calling this function does not alter the state of rng.
        rng(initial_rand_state);
    end %function draw_samples_from_distribution()

    % %% Define a function to draw a sequence of random numbers in a closed-open interval[0,1), ie with 0 <= x < 1.
    % function [uniform_variates] = co_rand(sz)
    %     %TODO: Find a good reference/description of how this works... Maybe check Knuth AoCP Vol 2.
    %     uri1 = bitshift(randi([0, 2^32-1], sz), -5); %Uniform random integers...floor(42 / 2.0^5) == bitshift(42, -5)
    %     uri2 = bitshift(randi([0, 2^32-1], sz), -6);
    %     %NOTE: %2.0^53 == 9007199254740992.0; %2.0^26 == 67108864.0
    %     uniform_variates = (uri1 .* 67108864.0 + uri2) ./ 9007199254740992.0; % Random double closed-open interval [0,1), ie includes 0, excludes 1.
    % end % function co_rand()

end %function alias_method()
