function SN_labels = dp_create_SN_labels(num_trials_per_subj, num_subj_per_grp, num_grps)

subj_per_grp=(1:num_subj_per_grp)';

r=repmat(subj_per_grp, 1, num_trials_per_subj)';

r=r(:)';

SN_labels = repmat(r,1,num_grps)';

end